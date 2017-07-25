require_relative 'samanage'
require 'awesome_print'

api_controller = Samanage::Api.new(token: ENV['SAMANAGE_TEST_API_TOKEN'],  development_mode: true)
# ap custom_fields

# puts "organize_forms: #{api_controller.organize_forms}"
ap api_controller.form_for(object_type: 'user')
# ap forms.keys
# ap forms['mobile']
# puts "organize_forms['mobile']: #{api_controller.organize_forms['mobile']['custom_form_fields']}"