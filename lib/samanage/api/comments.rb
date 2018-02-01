module Samanage
	class Api


		# Find comments given incident_id
		def get_comments(incident_id: )
			path = "incidents/#{incident_id}/comments.json"
			self.execute(path: path)
		end

		# Add a new comment
		def create_comment(incident_id: , comment: , options: {})
			path = "incidents/#{incident_id}/comments.json"
			self.execute(http_method: 'post', path: path, payload: comment)
		end


		alias_method :comments, :get_comments
	end
end