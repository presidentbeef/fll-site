require "rubygems"
require "sinatra"
require "./index"

set :environment, :production
$config_verifycaptcha = true
run Sinatra::Application
