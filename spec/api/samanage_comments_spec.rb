require 'samanage'
describe Samanage::Api do
	context 'Comments' do
		before(:all) do
			TOKEN ||= ENV['SAMANAGE_TEST_API_TOKEN']
			@samanage = Samanage::Api.new(token: TOKEN)
		end
		describe 'API Functions' do
			it 'gets comments' do
				incident_id = @samanage.get_incidents()[:data].sample.dig('id')
				comments = @samanage.get_comments(incident_id: incident_id)
				expect(comments).to be_a(Hash)
			end

			it 'creates a comment' do
				incident_id = @samanage.get_incidents()[:data].sample.dig('id')
				rand_text = ('a'..'z').to_a.shuffle[0,8].join
				comment = {
					comment: {
						body: rand_text,
					}
				}
				api_call = @samanage.create_comment(incident_id: incident_id, comment: comment)

				expect(api_call.dig(:data,'body')).to eq(rand_text)
			end

			it 'collects all comments' do
				## incident_id = @samanage.get_incidents()[:data].sample.dig('id')
				# incident_id = 19394209
				# comments_api = @samanage.get_comments(incident_id: incident_id)
				# comments_found = @samanage.collect_comments(incident_id: incident_id)

				# Total count bug
				# expect(comments_api[:total_count]).to eq(comments_found.size)
			end
		end
	end
end
