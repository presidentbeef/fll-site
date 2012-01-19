require "rubygems"
require "sinatra"
require "./index"

set :environment, :production
run Sinatra::Application
