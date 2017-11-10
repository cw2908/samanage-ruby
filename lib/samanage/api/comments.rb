module Samanage
	class Api


		# Find comments given incident_id
		def get_comments(incident_id: )
			path = "incidents/#{incident_id}/comments.json"
			api_call = self.execute(path: path)
			api_call
		end

		# Add a new comment
		def create_comment(incident_id: nil, comment: nil, options: {})
			path = "incidents/#{incident_id}/comments.json"
			api_call = self.execute(http_method: 'post', path: path, payload: comment)
			api_call
		end

		# Return all comments from the incident_id
		def collect_comments(incident_id: nil)

			page = 1
			max_pages = 5
			comments = Array.new
			while page <= max_pages
				path = "incidents/#{incident_id}/comments.json?page=#{page}"
				api_call = self.execute(path: path)
				comments += api_call[:data]
				page += 1
			end
			comments
		end
	end
end