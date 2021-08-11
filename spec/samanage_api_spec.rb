# frozen_string_literal: true

require "spec_helper"
describe Samanage do
  describe "API Controller" do
    before(:each) do
      TOKEN ||= ENV["SAMANAGE_TEST_API_TOKEN"]
    end
    context "on instantiation" do
      it "Requires Valid Token" do
        expect {
          api_controller = Samanage::Api.new(token: "invalid token")
          api_controller.authorize
        }.to raise_error(Samanage::AuthorizationError)
        expect { Samanage::Api.new(token: TOKEN) }.to_not raise_error
      end


      it "Validates Credentials on Creation" do
        # Valid Credentials
        expect(Samanage::Api.new(token: TOKEN)).to be_an_instance_of(Samanage::Api)
        # Invalid / Reversed Credentials
        expect {
          api_controller = Samanage::Api.new(token: "invalid")
          api_controller.authorize
        }.to raise_error(Samanage::AuthorizationError)
      end

      it "Finds all custom forms in development mode" do
        api_controller = Samanage::Api.new(token: TOKEN, development_mode: true)
        expect(api_controller).to be_an_instance_of(Samanage::Api)
        expect(api_controller.custom_forms).not_to be(nil)
        expect(api_controller.custom_forms).to be_a(Array)
      end
      it "Fails with invalid token in development mode" do
        expect {
          Samanage::Api.new(token: "Invalid Token", development_mode: true)
        }.to raise_error(Samanage::AuthorizationError)
      end

      # Search random Samanage::Api.list_admins user and verifiy role is admin
      it "Finds Admins" do
        api_controller = Samanage::Api.new(token: TOKEN)
        admins = api_controller.list_admins
        admin_email = admins.sample.gsub("+", "%2B")
        samanage_admin = api_controller.execute(path: "users.json", options: {'email[]': admin_email})
        expect(samanage_admin[:data].first["role"]["name"]).to eq("Administrator")
      end
      
      it 'Paginates' do 
        api_controller = Samanage::Api.new(token: TOKEN)
        incident_count = api_controller.incidents.count
        paginated_incident_count = api_controller._paginator(path: 'incidents.json').count
        expect(incident_count).to eq(paginated_incident_count)
      end

      it 'Paginates with options' do 
        api_controller = Samanage::Api.new(token: TOKEN)
        _opts = {'updated[]': 7}
        incident_count = api_controller.incidents(options: _opts).count
        paginated_incident_count = api_controller._paginator(path: 'incidents.json', options: _opts).count
        expect(incident_count).to eq(paginated_incident_count)
      end
      
      it 'Paginates Configuration with options' do 
        api_controller = Samanage::Api.new(token: TOKEN)
        _opts = {'updated[]': 7, verbose: true}
        incident_count = api_controller.configuration_items(options: _opts).count
        paginated_incident_count = api_controller._paginator(path: 'configuration_items.json', options: _opts).count
        expect(incident_count).to eq(paginated_incident_count)
      end
      it 'Paginates Users with options' do 
        api_controller = Samanage::Api.new(token: TOKEN)
        _opts = {'updated[]': 7}
        user_count = api_controller.users(options: _opts).count
        paginated_user_count = api_controller._paginator(path: 'users.json', options: _opts).count
        expect(user_count).to eq(paginated_user_count)
      end

      it "sets eu datacenter" do
        api_controller = Samanage::Api.new(token: "token", datacenter: "eu")
        expect(api_controller.base_url).to eq("https://apieu.samanage.com/")
      end
      

      it "does not set non/eu datacenter" do
        api_controller = Samanage::Api.new(token: "token", datacenter: "invalid")
        expect(api_controller.base_url).to eq("https://api.samanage.com/")
      end
    end
  end
end
