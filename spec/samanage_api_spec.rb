require 'spec_helper'
describe Samanage do
	describe 'API Controller' do
		before(:each) do
			TOKEN ||= ENV['SAMANAGE_TEST_API_TOKEN']
		end
	  context 'on creation' do
	  	it 'Requires Email & Token' do
	  		expect{
	  			api_controller = Samanage::Api.new(token: "invalid token")
	  			api_controller.authorize
	  		}.to raise_error(Samanage::AuthorizationError)
	  		expect{ Samanage::Api.new(token: TOKEN) }.to_not raise_error
	  	end

	  	it 'Validates Credentials on Creation' do
	  		# Valid Credentials
	  		expect(Samanage::Api.new(token: TOKEN)).to be_an_instance_of(Samanage::Api)
	  		# Invalid / Reversed Credentials
				expect{
					api_controller = Samanage::Api.new(token: 'invalid')
					api_controller.authorize
				}.to raise_error(Samanage::AuthorizationError)
  		end

  		it 'Finds all custom forms in development mode' do
  			api_controller = Samanage::Api.new(token: TOKEN, development_mode: true)
  			expect(api_controller).to be_an_instance_of(Samanage::Api)
  			expect(api_controller.custom_forms).not_to be(nil)
  			expect(api_controller.custom_forms).to be_a(Hash)
  		end
  		it 'Fails with invalid token in development mode' do
  			expect{ Samanage::Api.new(token: 'Invalid Token', development_mode: true)}.to raise_error(Samanage::AuthorizationError)
  		end

  		# Search random Samanage::Api.list_admins user and verifiy role is admin
  		it 'Finds Admins' do
  			api_controller = Samanage::Api.new(token: TOKEN, development_mode: true)
  			admins = api_controller.list_admins
  			admin_email = admins.sample.gsub('+',"%2B")
  			samanage_admin = api_controller.execute(path: "users.json?email=#{admin_email}")
  			expect(samanage_admin[:data].first['role']['name']).to eq('Administrator')
  		end

  		it 'sets eu datacenter' do
  			api_controller = Samanage::Api.new(token: 'token', datacenter: 'eu')
  			expect(api_controller.base_url).to eq('https://apieu.samanage.com/')
  		end

  		it 'does not set non/eu datacenter' do
  			api_controller = Samanage::Api.new(token: 'token', datacenter: 'invalid')
  			expect(api_controller.base_url).to eq('https://api.samanage.com/')
  		end
	  end
	end
end