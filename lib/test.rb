require_relative 'samanage'
require 'awesome_print'

api_controller = Samanage::Api.new(token: ENV['SAMANAGE_TEST_API_TOKEN'],  development_mode: true)

api_call = api_controller.execute(path: 'incidents.json?layout=long')
ap api_call
puts api_call[:data].keys