source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.7.1"

gem "rails", "~> 6.0.3", ">= 6.0.3.3"

# Basics
gem "bootsnap", ">= 1.4.2", require: false
gem "pg", ">= 0.18", "< 2.0"
gem "puma", "~> 4.1"
gem "foundation-rails"
gem "autoprefixer-rails"
gem "inky-rb", require: "inky"
# Stylesheet inlining for email
gem "premailer-rails"
# Auth
gem "devise_token_auth", "~> 1.1.4"

# Cors
gem "rack-cors", "~> 1.1.1"
# translate messages
gem "rails-i18n"

gem "jbuilder", "~> 2.10.1"

gem "pry"

group :development, :test do
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  gem "rspec-rails", "~> 4.0.1"
  gem "factory_bot_rails"
  gem "shoulda-matchers", "~> 4.0"
  gem "faker"
end

group :development do
  gem "listen", "~> 3.2"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
end

gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]
