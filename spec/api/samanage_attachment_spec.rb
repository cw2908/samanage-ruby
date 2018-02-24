
require 'samanage'
describe Samanage::Api do
  context 'Attachments' do
    describe 'API Functions' do
      before(:all) do 
        TOKEN ||= ENV['SAMANAGE_TEST_API_TOKEN']
        @samanage = Samanage::Api.new(token: TOKEN)
        @users = @samanage.get_users[:data]
        @incidents = @samanage.incidents
      end
    end
  end
end