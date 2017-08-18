require_relative 'lib/samanage'
require 'awesome_print'
api_controller = Samanage::Api.new(token: ENV['SAMANAGE_TEST_API_TOKEN'])
ap api_controller
api_controller.collect_users