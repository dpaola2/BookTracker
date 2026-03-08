source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.2"

gem "annotate"
gem "aws-sdk-s3", require: false
gem "devise"
gem "image_processing", "~> 1.2"
gem "importmap-rails"
gem "isbndb-ruby"
gem "jbuilder"
gem "pagy"
gem "puma", "~> 5.0"
gem "rails", "~> 7.0.4", ">= 7.0.4.3"
gem "ransack"
gem "redcarpet"
gem "redis", "~> 4.0"
gem "sassc-rails"
gem "sprockets-rails"
gem "sqlite3"
gem "stimulus-rails"
gem "turbo-rails"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "brakeman", require: false
  gem "debug", platforms: %i[mri mingw x64_mingw]
  gem "rubocop", require: false
  gem "rubocop-minitest", require: false
  gem "rubocop-rails", require: false
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "better_errors"
  gem "binding_of_caller"
  gem "web-console"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
  gem "simplecov", require: false
  gem "webdrivers"
end
