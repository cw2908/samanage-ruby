require 'samanage'
describe Samanage::Api do
	context 'Util' do
    describe 'API Functions' do
      before(:each) do 
        TOKEN ||= ENV['SAMANAGE_TEST_API_TOKEN']
        @controller = Samanage::Api.new(token: TOKEN)
      end
      it 'sends an activation email' do
        real_email = @controller.users.sample['email'] 
        send_email = @controller.send_activation_email(email: real_email)
        puts "Send Email: #{send_email.inspect}"
        exepct(send_email[:code]).to be(200)
      end
      it 'fails for invalid email' do
        false_email = @controller.users.sample['email'].gsub!('@','$')
        send_email = @controller.send_activation_email(email: false_email)
      end
    end
  end
end