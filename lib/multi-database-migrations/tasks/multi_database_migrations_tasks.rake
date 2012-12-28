module MultiMigrations
  def self.make_connection(db_name)
    raise "DATABASE is required" unless db_name
    connection_key = self.identify_configuration(db_name)
    raise "VALID DATABASE is required" unless connection_key
    ActiveRecord::Base.establish_connection(connection_key)
  end

  def self.identify_configuration(db_name)
    if ActiveRecord::Base.configurations.has_key?("#{db_name}_#{Rails.env}")
      return "#{db_name}_#{Rails.env}"
    else
      match = ActiveRecord::Base.configurations.find { |config| config[1]['database'] == db_name }
      return match[0] unless match.nil?
    end
  end
end

namespace :db do
  namespace :multi do
    desc "Migrate through the scripts in db/migrate/<dbname>/ Target specific version with VERSION=x. Turn off output with VERBOSE=false."
    task :migrate, [:db] => [:environment] do |t, args|
      database = ENV['DATABASE'] || args[:db]
      MultiMigrations.make_connection(database)
      ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
      ActiveRecord::Migrator.migrate("db/migrate/#{database}", ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
      Rake::Task["db:multi:schema:dump"].invoke(database) if ActiveRecord::Base.schema_format == :ruby
    end

    namespace :migrate do
      desc  'Rollbacks the database one migration and re migrate up. If you want to rollback more than one step, define STEP=x'
      task :redo => [ 'db:multi:rollback', 'db:multi:migrate' ]

     # TODO: Implement db:multi:drop, db:multi:create
     #desc 'Resets your database using your migrations for the current environment'
     #task :reset => ["db:multi:drop", "db:multi:create", "db:multi:migrate"]

      desc 'Runs the "up" for a given migration VERSION.'
      task :up, [:db] => [:environment] do |t, args|
        database = ENV['DATABASE'] || args[:db]
        version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
        raise "VERSION is required" unless version
        MultiMigrations.make_connection(database)
        ActiveRecord::Migrator.run(:up, "db/migrate/#{database}", version)
        Rake::Task["db:multi:schema:dump"].invoke(database) if ActiveRecord::Base.schema_format == :ruby
      end

      desc 'Runs the "down" for a given migration VERSION.'
      task :down, [:db] => [:environment] do |t, args|
        database = ENV['DATABASE'] || args[:db]
        version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
        raise "VERSION is required" unless version
        MultiMigrations.make_connection(database)
        ActiveRecord::Migrator.run(:down, "db/migrate/#{database}", version)
        Rake::Task["db:multi:schema:dump"].invoke(database) if ActiveRecord::Base.schema_format == :ruby
      end
    end

    desc 'Rolls the schema back to the previous version. Specify the number of steps with STEP=n'
    task :rollback, [:db] => [:environment] do |t, args|
      database = ENV['DATABASE'] || args[:db]
      step = ENV['STEP'] ? ENV['STEP'].to_i : 1
      MultiMigrations.make_connection(database)
      ActiveRecord::Migrator.rollback("db/migrate/#{database}", step)
      Rake::Task["db:multi:schema:dump"].invoke(database) if ActiveRecord::Base.schema_format == :ruby
    end


    namespace :schema do
      desc "Create a db/schema.rb file that can be portably used against any DB supported by AR"
      task :dump, [:db] => [:environment] do |t, args|
        database = ENV['DATABASE'] || args[:db]
        MultiMigrations.make_connection(database)
        require 'active_record/schema_dumper'
        File.open(ENV['SCHEMA'] || "db/schema_#{database}.rb", "w:utf-8") do |file|
          ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
        end
      end

      desc "Load a schema.rb file into the database"
      task :load, [:db] => [:environment] do |t, args|
        database = ENV['DATABASE'] || args[:db]
        file = ENV['SCHEMA'] || "db/schema_#{database}.rb"
        load(file)
      end
    end

  end
end
