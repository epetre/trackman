require 'rest-client'
require 'trackman'

#only load this rakefil for sinatra/rack apps 
namespace :trackman do
  desc "Syncs your assets with the server, this is what gets executed when you deploy to heroku."
  task :sync do 
    Trackman::Assets::Asset.sync
  end

  desc "Sets up the heroku configs required by Trackman"
  task :setup, :app do |t, args|
    heroku_version = Gem.loaded_specs["heroku"].version.to_s
    Trackman::Utility::Configuration.new(heroku_version, :app => args[:app]).setup
  end
end