# frozen_string_literal: true

source "https://rubygems.org"

gem "httparty", "0.16.4"
gem "ffi", "1.9.24"

group :development do
  gem "rspec"
  gem "rubocop", require: false
  gem "rubocop-performance"
end


group :development, :test do
  gem "guard-rspec", require: false
  gem "guard"
  gem "dotenv"
  gem "pry-byebug"
  gem "byebug"
end

group :test do
  gem "faker"
end
