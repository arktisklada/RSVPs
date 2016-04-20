require 'rubygems'
require 'sinatra'

Sinatra::Application.default_options.merge!( 
  run: false, 
  env: :production 
)

load 'app.rb'
run Sinatra.application