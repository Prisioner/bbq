source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.1.3'
gem 'puma', '~> 3.7'
gem 'uglifier', '>= 1.3.0'

gem 'jquery-rails'
gem 'owlcarousel-rails'

gem 'slim-rails'
gem 'twitter-bootstrap-rails'

gem 'devise'
gem 'devise-i18n'

gem 'rails-i18n', '~> 5.0.0'

gem 'carrierwave'
gem 'rmagick'
gem 'fog-google'
gem 'google-api-client', '~> 0.8.6'

gem 'recaptcha', require: 'recaptcha/rails'

group :development, :test do
  gem 'sqlite3'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'shoulda-matchers'
  gem 'rails-controller-testing'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
end

group :production do
  gem 'pg'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
