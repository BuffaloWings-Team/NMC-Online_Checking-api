# frozen_string_literal: true

source 'https://rubygems.org'

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

# Performance
gem 'rubocop-performance'

group :production do 
  gem 'pg'
end

# Testing
group :test do
  gem 'minitest'
  gem 'minitest-rg'
end

# Development
group :development do
  gem 'pry'
  gem 'rerun'
  gem 'rubocop'
  gem 'rubocop-performance'
end

group :development, :test do
  gem 'rack-test'
  gem 'sequel-seed'
  gem 'sqlite3', '~>1.6'
end

# Quality
gem 'rubocop'

