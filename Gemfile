source 'https://rubygems.org'


gem 'rails', '4.2.5.1'

gem 'rails-api', '0.4.0' #specifying versions is good for avoiding surprises!

# Not needed for a model project, and can sometimes cause errors with RSpec+FactoryGirl
# gem 'spring', :group => :development


gem 'sqlite3' #then again, that's what Gemfile.lock is for!

# GEMs I'm adding

# WEBrick and Windows play nicely if we include this (otherwise error trying to find timezone info -- yet
# using timezones and localization still requires other steps. Hooray? :P)
gem 'tzinfo-data' , platforms: [:mingw, :mswin, :x64_mingw]

# because versioning is important, and Versionist is simpler than RocketPants
# however, not using versions for this project -- see README for why.
#gem 'versionist'

# RocketPants has some nice JSON features I've always wanted to try out, so....
gem 'rocket_pants'

# rspec for testing ease
gem 'rspec'
gem 'rspec-rails'

# Factory Girl (because fixing fixtures is a pain)
gem 'factory_girl'
gem 'factory_girl_rails', require: false

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
  gem 'redcarpet', '~> 3.1.2'
end
