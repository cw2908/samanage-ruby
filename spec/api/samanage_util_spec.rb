require 'samanage'
describe Samanage::Api do
	context 'Utils' do
    describe 'API Functions' do
      before(:each) do 
        TOKEN ||= ENV['SAMANAGE_TEST_API_TOKEN']
        @controller = Samanage::Api.new(token: TOKEN)
      end
      it 'sends an activation email' do
        valid_email = @controller.users.sample['email'] 
        send_email = @controller.send_activation_email(email: valid_email)
        expect(send_email[:code]).to be(200)
      end
      it 'fails for invalid email' do
        invalid_email = @controller.users.sample['email'].gsub!('@','$')
        expect{@controller.send_activation_email(email: invalid_email)}.to raise_error(Samanage::Error)
      end
    end
  end
end