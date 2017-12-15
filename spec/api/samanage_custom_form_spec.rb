require 'samanage'

describe Samanage::Api do
	context 'Custom Form' do
		describe 'API Functions' do
			before(:each) do
				TOKEN ||= ENV['SAMANAGE_TEST_API_TOKEN']
				@controller = Samanage::Api.new(token: TOKEN, development_mode: true)
			end
			it 'collects all custom forms' do
				api_call = @controller.collect_custom_forms
				expect(api_call).to be_a(Array)
			end
			it 'Organizes custom forms by module' do
				api_call = @controller.organize_forms
				expect(api_call).to be_a(Hash)
				expect(api_call.keys).to be_an(Array)
				# expect(api_call[api_call.keys.sample].sample).to be_a(Hash)
			end
			it 'Finds the forms for an object_type' do
				object_types = ['incident', 'user','other_asset','hardware','configuration_item']
				form = @controller.form_for(object_type: object_types.sample)
				expect(form).to be_an(Array)
				expect(form.sample.keys).to include('custom_form_fields')
			end
		end
	end
end
