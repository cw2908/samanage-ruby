require 'samanage'
describe Samanage::Api do
  context 'Utils' do
    describe 'API Functions' do
      before(:all) do 
        TOKEN ||= ENV['SAMANAGE_TEST_API_TOKEN']
        @samanage = Samanage::Api.new(token: TOKEN)
        @users = @samanage.get_users[:data]
        @incidents = @samanage.incidents
      end
      it 'sends an activation email' do
        valid_email = @users.select{|u| u['email'].match(/samanage/)}.sample['email']
        send_email = @samanage.send_activation_email(email: valid_email)
        expect(send_email[:code]).to eq(200)
      end
      it 'fails for invalid email' do
        invalid_email = @samanage.users.sample['email'].gsub!('@','$')
        expect{@samanage.send_activation_email(email: invalid_email)}.to raise_error(Samanage::Error)
      end
    end
  end
end