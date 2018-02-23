
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
      it 'uploads an attachment' do
        filename = 'sample_file.txt'
        attachment = File.open(filename)
        incident_id = @incidents.sample.dig('id')
        attach = @samanage.upload_attachment(
          attachment: attachment,
          attachable_id: incident_id,
          attachable_type: 'Incident'
        )
        expect(attach[:code]).to eq(200).or(201)
        expect(filename).to eq(attach[:data]['filename'])
        expect(attachment.size).to eq(attach[:data]['size'])
      end
      it 'downloads an attachment' do
        incident_id = @incidents.sample.dig('id')
        filename = 'sample_file.txt'
        attachment = File.open(filename)
        attach = @samanage.upload_attachment(
          attachment: attachment,
          attachable_id: incident_id,
          attachable_type: 'Incident'
        )
        attachable_incident_id = incident_id # Need filter for has attachment?
        incident = @samanage.find_incident(id: attachable_incident_id, options: {layout: 'long'})
        attachment = @samanage.download_attachment(attachment: incident[:data]['attachments'].first)
        expect(attachment.class).to be(File)
        expect(attach[:code]).to eq(200)
        expect(attachment.path.split('/').last).to eq(filename)
      end
    end
  end
end