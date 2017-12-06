module Samanage
	class Api

		def get_groups(path: PATHS[:group], options: {})
			url = Samanage::UrlBuilder.new(path: path, options: options).url
			self.execute(path: url)
		end

		def collect_groups
			page = 1
			groups = Array.new
			total_pages = self.get_groups[:total_pages]
			while page <= total_pages
				groups += self.execute(http_method: 'get', path: "groups.json?page=#{page}")[:data]
				page += 1
			end
			groups
		end

		def create_group(payload: nil, options: {})
			self.execute(path: PATHS[:group], http_method: 'post', payload: payload)
		end

		def add_member_to_group(email: nil, group_id: nil)
			user_id = self.find_user_id_by_email(email: email)
			member_path = "memberships.json?group_id=#{group_id}.json&user_ids=#{user_id}"
			self.execute(path: member_path, http_method: 'post')
		end
	end
end