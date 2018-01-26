module Samanage
	class Api


		# Find comments given incident_id
		def get_comments(incident_id: )
			path = "incidents/#{incident_id}/comments.json"
			self.execute(path: path)
		end

		# Add a new comment
		def create_comment(incident_id: nil, comment: nil, options: {})
			path = "incidents/#{incident_id}/comments.json"
			self.execute(http_method: 'post', path: path, payload: comment)
		end

		# Return all comments from the incident_id
		def collect_comments(incident_id: nil)

			page = 1
			max_pages = 5
			comments = Array.new
			while page <= max_pages
				path = "incidents/#{incident_id}/comments.json?page=#{page}"
				comments += self.execute(path: path)[:data]
				page += 1
			end
			comments
		end

		alias_method :comments, :collect_comments
	end
end