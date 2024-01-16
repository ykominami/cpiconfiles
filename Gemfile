# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in cpiconfiles.gemspec
gemspec

gem 'loggerx', '~> 0.2.0'
gem 'rake', '~> 13.0'

group :test, :development, optional: true do
  gem 'rspec', '~> 3.0'
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rake', require: false
  gem 'rubocop-rspec', require: false
end

group :development do
  gem 'debug', platforms: %i[mri mswin mswin64 mingw x64_mingw]
  gem 'rufo'
  gem 'yard'
end
