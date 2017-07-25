require 'samanage'

describe Samanage::Api do
	context 'Custom Field' do
		describe 'API Functions' do
			before(:each) do
				TOKEN ||= ENV['SAMANAGE_TEST_API_TOKEN']
				@controller = Samanage::Api.new(token: TOKEN)
			end
			it 'collects all custom fields' do
				api_call = @controller.collect_custom_fields
				expect(api_call).to be_a(Array)
			end
		end
	end
end
