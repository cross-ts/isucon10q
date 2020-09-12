require './app'
require 'sinatra/config_file'
config_file 'config/newrelic.yml'

run App
