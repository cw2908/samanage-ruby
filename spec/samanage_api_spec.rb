require 'spec_helper'
describe Samanage do
	describe 'API Controller' do
		before(:each) do
			TOKEN ||= ENV['SAMANAGE_TEST_API_TOKEN']
		end
	  context 'on creation' do
	  	it 'Requires Email & Token' do
	  		expect{ Samanage::Api.new() }.to raise_error(ArgumentError)
	  		expect{ Samanage::Api.new(token: "invalid token") }.to raise_error(Samanage::AuthorizationError)
	  		expect{ Samanage::Api.new(token: TOKEN) }.to_not raise_error
	  	end

	  	it 'Validates Credentials on Creation' do
	  		# Valid Credentials
	  		expect(Samanage::Api.new(token: TOKEN)).to be_an_instance_of(Samanage::Api)
	  		# Invalid / Reversed Credentials
				expect{Samanage::Api.new(token: 'invalid')}.to raise_error(Samanage::AuthorizationError)
				expect(Samanage::Api.new(token: TOKEN).custom_forms).to be(nil)
  		end

  		it 'Finds all custom forms in development mode' do
  			api_controller = Samanage::Api.new(token: TOKEN, development_mode: true)
  			expect(api_controller).to be_an_instance_of(Samanage::Api)
  			expect(api_controller.custom_forms).not_to be(nil)
  			expect(api_controller.custom_forms).to be_a(Hash)
  		end
	  end
	end
end