module Samanage
	class Api
		def get_groups(path: PATHS[:group], options: {})
			url = Samanage::UrlBuilder.new(path: path, options: options).url
			self.execute(path: url)
		end

		def collect_groups(options: {})
			page = 1
			groups = Array.new
			total_pages = self.get_groups[:total_pages]
			1.upto(total_pages) do |page|
				puts "Collecting Groups page: #{page}/#{total_pages}" if options[:verbose]
				groups += self.execute(http_method: 'get', path: "groups.json?page=#{page}")[:data]
			end
			groups
		end

		def create_group(payload: , options: {})
			self.execute(path: PATHS[:group], http_method: 'post', payload: payload)
		end

		def find_group_id_by_name(group: )
			group_api = self.execute(path: "groups.json?name=#{group}")
			if !group_api[:data].empty? && group == group_api[:data].first['name']
				return group_api[:data].first['id']
			end
		end

		def find_group(id: )
			path = "groups/#{id}.json"
			self.execute(path: path)
		end

		def add_member_to_group(email: , group_id: nil, group_name: nil)
			group_id = group_id ||= self.find_group_id_by_name(group: group_name)
			user_id = self.find_user_id_by_email(email: email)
			member_path = "memberships.json?group_id=#{group_id}.json&user_ids=#{user_id}"
			self.execute(path: member_path, http_method: 'post')
		end
		
		def delete_group(id: )
      self.execute(path: "groups/#{id}.json", http_method: 'delete')
    end
		
		alias_method :groups, :collect_groups
	end
end