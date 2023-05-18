# frozen_string_literal: true

source 'https://rubygems.org'
ruby File.read('.ruby-version').strip

# Web API
gem 'json'
gem 'puma', '~>5.6'
gem 'roda', '~>3.54'

# Configuration
gem 'figaro'
gem 'rake'

# Security
gem 'bundler-audit'
gem 'rbnacl', '~>7.1'

# Database
gem 'hirb'
gem 'sequel', '~>5.55'

group :production do
  gem 'pg'
end

# Testing
group :test do
  gem 'minitest'
  gem 'minitest-rg'
end

# Debugging
gem 'pry'

# Development
group :development do
  gem 'rerun'

  # Quality
  gem 'rubocop'
  gem 'rubocop-performance'
end

group :development, :test do
  gem 'rack-test'
  gem 'sequel-seed'
  gem 'sqlite3', '~>1.6'
end