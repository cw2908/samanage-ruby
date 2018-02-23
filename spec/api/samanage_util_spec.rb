require 'samanage'
describe Samanage::Api do
	context 'Utils' do
    describe 'API Functions' do
      before(:each) do 
        TOKEN ||= ENV['SAMANAGE_TEST_API_TOKEN']
        @samanage = Samanage::Api.new(token: TOKEN)
        @users = @samanage.get_users[:data]
      end
      it 'sends an activation email' do
        valid_email = @users.sample['email'] 
        send_email = @samanage.send_activation_email(email: valid_email)
        expect(send_email[:code]).to be(200)
      end
      it 'fails for invalid email' do
        invalid_email = @samanage.users.sample['email'].gsub!('@','$')
        expect{@samanage.send_activation_email(email: invalid_email)}.to raise_error(Samanage::Error)
      end
      it 'downloads an attachment' do
        # attachable_incident_id = 22215549 # Need filter for has attachment?
        # incident = @samanage.find_incident(id: attachable_incident_id, options: {layout: 'long'})
        # attachment = @samanage.download_attachment(attachment: incident[:data]['attachments'].first)
        # expect(attachment.class).to be(File)
      end
    end
  end
end