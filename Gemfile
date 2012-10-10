source 'https://rubygems.org'

gem 'rails', '3.2.8'
gem 'mysql2'
gem 'devise', git: "git@github.com:diminish7/devise.git", branch: "failure_app_test_helper"
gem 'jquery-rails'

gem 'aasm'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

group :test, :development do
  gem 'rspec-rails', '~> 2.0'
  gem 'debugger', group: [:development, :test]
end

group :test do
  gem 'factory_girl_rails', '~> 4.0'
end