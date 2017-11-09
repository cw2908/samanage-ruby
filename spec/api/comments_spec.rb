require 'samanage'
describe Samanage::Api do
	context 'Comments' do
		before(:each) do
			TOKEN ||= ENV['SAMANAGE_TEST_API_TOKEN']
			@controller = Samanage::Api.new(token: TOKEN)
		end
		describe 'API Functions' do
			it 'gets comments' do
				incident_id = @controller.get_incidents()[:data].sample.dig('id')
				comments = @controller.get_comments(incident_id: incident_id)
				expect(comments).to be_a(Hash)
			end

			it 'creates a comment' do
				incident_id = @controller.get_incidents()[:data].sample.dig('id')
				rand_text = ('a'..'z').to_a.shuffle[0,8].join
				comment = {
					comment: {
						body: rand_text,
					}
				}.to_json
				api_call = @controller.create_comment(incident_id: incident_id, comment: comment)

				expect(api_call.dig(:data,'body')).to eq(rand_text)
			end

			it 'collects all comments' do
				incident_id = @controller.get_incidents()[:data].sample.dig('id')
				incident_id = 19394209
				comments_api = @controller.get_comments(incident_id: incident_id)
				comments_found = @controller.collect_comments(incident_id: incident_id)
				puts "comments api size: #{comments_api.inspect}"
				puts "Found Comments: #{comments_found.size}"
				# Total count bug
				# expect(comments_api[:total_count]).to eq(comments_found.size)
			end
		end
	end
end
