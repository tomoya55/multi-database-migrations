require 'rubygems'
require 'test/unit'
require 'shoulda'

# require 'bundler'
# Bundler.setup

ENV['RAILS_ENV'] = 'test'

$:.unshift File.dirname(__FILE__)

require "rails"
require "active_record"
require "rails/test_help"
require "rails/generators"
require "rails/generators/rails/migration/migration_generator"