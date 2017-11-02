module Samanage
	class Api

	def get_users(path: PATHS[:user], options: {})
    url = Samanage::UrlBuilder.new(path: path, options: options).url
    api_call = self.execute(path: url)
    api_call
  end

  # Returns all users in the account
		def collect_users
			page = 1
			users = Array.new
			total_pages = self.get_users[:total_pages]
			while page <= total_pages
				api_call = self.execute(http_method: 'get', path: "users.json?page=#{page}")
				users += api_call[:data]
				page += 1
			end
			users
		end

		def create_user(payload: nil, options: {})
			api_call = self.execute(path: PATHS[:user], http_method: 'post', payload: payload)
			api_call
    end

    # Find user by id
    def find_user(id: nil)
			path = "users/#{id}.json"
			api_call = self.execute(path: path)
			api_call
		end

		# Email is unique so compare first for exact match only. Return [nil..id]
		def find_user_id_by_email(email: nil)
			api_call = self.check_user(value: email)
			api_call.dig(:data).first.to_h.dig('email').to_s.downcase == email.to_s.downcase ? api_call.dig(:data).first.dig('id') : nil
		end

    # Check for user by field (ex: users.json?field=value)
		def check_user(field: 'email', value: nil)
			url = "users.json?#{field}=#{value}"
			api_call = self.execute(path: url)
			api_call
		end

    # Update user by id
		def update_user(payload: nil, id: nil)
			path = "users/#{id}.json"
			api_call = self.execute(path: path, http_method: 'put', payload: payload)
			api_call
		end
	end
end