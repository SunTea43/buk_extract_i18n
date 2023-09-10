# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in extract_i18n.gemspec
gemspec

gem 'pry'
gem 'rake'
gem 'solargraph'
gem "ruby-openai"

group :test do
  gem 'webmock'
  gem 'byebug'
  gem 'rubocop'
  gem 'rspec'
end