# -*- encoding: utf-8 -*-
require File.expand_path('../lib/multi-database-migrations/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["jystewart", "chrisrohr", "sinsoku"]
  gem.email         = ["jys@ketlai.co.uk", "crohr@nearinfinity.com", "sinsoku.listy@gmail.com"]
  gem.description   = %q{A plugin to make it easier to host migrations for multiple databases in one rails app.}
  gem.summary       = %q{multi-datbase-migrations}
  gem.homepage      = "https://github.com/chrisrohr/multi-datbase-migrations"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "multi-database-migrations"
  gem.require_paths = ["lib"]
  gem.version       = Multi::Database::Migrations::VERSION

  gem.add_development_dependency 'bundler', ['>= 1.0.0']
  gem.add_development_dependency 'rake', ['> 0']
  gem.add_development_dependency 'rails', ['> 3.2.0']
  gem.add_development_dependency 'shoulda', ['> 0']
end
