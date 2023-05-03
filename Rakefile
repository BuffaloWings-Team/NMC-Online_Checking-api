# frozen_string_literal: true

require 'rake/testtask'
require './require_app'

# rubocop:disable Style/HashSyntax, Style/SymbolArray
task :default => :spec

desc 'Tests API specs only'
task :api_spec do
  sh 'ruby spec/api_spec.rb'
end

desc 'Test all the specs'
Rake::TestTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.warning = false
end

desc 'Rerun tests on live code changes'
task :respec do
  sh 'rerun -c rake spec'
end

desc 'Runs rubocop on tested code'
task :style => [:spec, :audit] do
  sh 'rubocop .'
end

desc 'Update vulnerabilities lit and audit gems'
task :audit do
  sh 'bundle audit check --update'
end

desc 'Checks for release'
task :release? => [:spec, :style, :audit] do
  puts "\nReady for release!"
end

task :print_env do
  puts "Environment: #{ENV['RACK_ENV'] || 'development'}"
end

desc 'Run application console (pry)'
task :console => :print_env do
  sh 'pry -r ./spec/test_load_all'
end

namespace :db do
  require_app(nil) # load config code files only
  require 'sequel'

  Sequel.extension :migration
  app = OnlineCheckIn::Api

  desc 'Run migrations'
  task :migrate => :print_env do
    puts 'Migrating database to latest'
    Sequel::Migrator.run(app.DB, 'app/db/migrations')
  end

  desc 'Deletes the database'
  task :delete do
    app.DB[:members].delete
    app.DB[:households].delete
  end

  desc 'Delete dev or test database file'
  task :drop do
    if app.environment == :production
      puts 'Cannot wipe production database!'
      return
    end

    db_filename = "app/db/store/#{OnlineCheckIn::Api.environment}.db"
    FileUtils.rm(db_filename)
    puts "Deleted #{db_filename}"
  end

  desc 'Delete all database file'
  task :dropAll do
    if app.environment == :production
      puts 'Cannot wipe production database!'
      return
    end
    Dir.glob('app/db/store/*.db').each { |filename| FileUtils.rm(filename)}
    puts "Deleted all the db files"
  end

  task :load_models do
    require_app(%w[lib models services])
  end

  task :reset_seeds => [:load_models] do
    app.DB[:schema_seeds].delete if app.DB.tables.include?(:schema_seeds)
    OnlineCheckIn::Account.dataset.destroy
  end

  desc 'Seeds the development database'
  task :seed => [:load_models] do
    require 'sequel/extensions/seed'
    Sequel::Seed.setup(:development)
    Sequel.extension :seed
    Sequel::Seeder.apply(app.DB, 'app/db/seeds')
  end

  desc 'Delete all data and reseed'
  task reseed: [:reset_seeds, :seed]
end

namespace :newkey do
  desc 'Create sample cryptographic key for database'
  task :db do
    require_app('lib')
    puts "DB_KEY: #{SecureDB.generate_key}"
  end
end
# rubocop:enable Style/HashSyntax, Style/SymbolArray
