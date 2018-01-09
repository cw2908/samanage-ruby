require 'samanage'

describe Samanage::Api do
	context 'Custom Form' do
		describe 'API Functions' do
			before(:all) do
				TOKEN ||= ENV['SAMANAGE_TEST_API_TOKEN']
				@samanage = Samanage::Api.new(token: TOKEN, development_mode: true)
				@custom_forms = @samanage.custom_forms
			end
			it 'collects all custom forms' do
				expect(@custom_forms).to be_a(Array)
			end
			it 'Organizes custom forms by module' do
				api_call = @samanage.organize_forms
				expect(api_call).to be_a(Hash)
				expect(api_call.keys).to be_an(Array)
				# expect(api_call[api_call.keys.sample].sample).to be_a(Hash)
			end
			it 'Finds the forms for an object_type' do
				object_types = ['incident', 'user','other_asset','hardware','configuration_item']
				form = @samanage.form_for(object_type: object_types.sample)
				expect(form).to be_an(Array)
				expect(form.sample.keys).to include('custom_form_fields')
			end
		end
	end
end
