require 'test_helper'
require 'generators/multi_migration/multi_migration_generator'

class MultiMigrationGeneratorTest < Rails::Generators::TestCase
  destination "tmp"
  setup :prepare_destination
  tests ::MultiMigrationGenerator
  
  context "MultiMigrationGenerator" do
    should "create the migrations in the specific database folders" do
      run_generator %w(create_table_in_test_db_1 test_db1 --orm active_record)
      assert_migration "db/migrate/test_db1/create_table_in_test_db_1"

      run_generator %w(create_table_in_test_db_2 test_db2 --orm active_record)
      assert_migration "db/migrate/test_db2/create_table_in_test_db_2"
    end
  end
end