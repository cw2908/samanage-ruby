# frozen_string_literal: true

source "https://rubygems.org"

gem "httparty", "0.16.4"
gem "ffi", "1.9.24"

group :development do
  gem "rspec"
end


group :development, :test do
  gem "guard-rspec", require: false
  gem "guard"
  gem "dotenv"
end

group :test do
  gem "faker"
end

gem "parallel", "~> 1.17"

gem "rubocop", "~> 1.18"
gem "rubocop-performance", "~> 1.4"
gem "rubocop-rails", "~> 2.11"

gem "byebug", "~> 11.1", :group => :development

gem 'parallel_tests', group: %i[development test]
