module Samanage
	class Api
		def get_departments(path: PATHS[:department], options: {})
			url = Samanage::UrlBuilder.new(path: path, options: options).url
			self.execute(path: url)
		end

		def collect_departments
			page = 1
			departments = Array.new
			total_pages = self.get_departments[:total_pages]
			while page <= total_pages
				departments += self.execute(http_method: 'get', path: "departments.json?page=#{page}")[:data]
				page += 1
			end
			departments
		end

		def create_department(payload: nil, options: {})
			self.execute(path: PATHS[:department], http_method: 'post', payload: payload)
		end


		alias_method :departments, :collect_departments
	end
end