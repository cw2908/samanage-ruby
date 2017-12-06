module Samanage
	class Api


	# Get users, using URL builder
	def get_users(path: PATHS[:user], options: {})
    url = Samanage::UrlBuilder.new(path: path, options: options).url
    self.execute(path: url)
	end

  # Returns all users in the account
		def collect_users
			page = 1
			users = Array.new
			total_pages = self.get_users[:total_pages]
			while page <= total_pages
				users += self.execute(http_method: 'get', path: "users.json?page=#{page}")[:data]
				page += 1
			end
			users
		end

		# Create user given JSON
		def create_user(payload: nil, options: {})
			self.execute(path: PATHS[:user], http_method: 'post', payload: payload)
		end

    # Return user by ID
    def find_user(id: nil)
			path = "users/#{id}.json"
			self.execute(path: path)
		end

		# Email is unique so compare first for exact match only. Returns nil or the id
		def find_user_id_by_email(email: nil)
			api_call = self.check_user(value: email)
			api_call.dig(:data).first.to_h.dig('email').to_s.downcase == email.to_s.downcase ? api_call.dig(:data).first.dig('id') : nil
		end

		# Returns nil if no matching group_id
		def find_user_group_id_by_email(email: nil)
			user = self.check_user(value: email)
			group_ids = user[:data].select{|u| u['email'] == email}.first['group_ids']
			group_ids.each do |group_id|
				group = self.find_group(id: group_id)
				if group[:data]['is_user'] && email == group[:data]['email']
					return group_id
				end
			end
			return
		end

    # Check for user by field (ex: users.json?field=value)
		def check_user(field: 'email', value: nil)
			if field.to_s.downcase == 'email'
				value = value.gsub("+",'%2B')
			end
			url = "users.json?#{field}=#{value}"
			self.execute(path: url)
		end

    # Update user by id
		def update_user(payload: nil, id: nil)
			path = "users/#{id}.json"
			self.execute(path: path, http_method: 'put', payload: payload)
		end
	end
end