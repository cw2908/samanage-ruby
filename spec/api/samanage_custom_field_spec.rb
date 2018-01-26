require 'samanage'

describe Samanage::Api do
	context 'Custom Field' do
		describe 'API Functions' do
			before(:all) do
				TOKEN ||= ENV['SAMANAGE_TEST_API_TOKEN']
				@samanage = Samanage::Api.new(token: TOKEN)
				@custom_fields = @samanage.custom_fields
			end
			it 'collects all custom fields' do
				expect(@custom_fields).to be_a(Array)
			end
		end
	end
end
