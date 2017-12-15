module Samanage
	class Api
		def get_sites(path: PATHS[:site], options: {})
			url = Samanage::UrlBuilder.new(path: path, options: options).url
			self.execute(path: url)
		end

		def collect_sites
			page = 1
			sites = Array.new
			total_pages = self.get_sites[:total_pages]
			while page <= total_pages
				sites += self.execute(http_method: 'get', path: "sites.json?page=#{page}")[:data]
				page += 1
			end
			sites
		end

		def create_site(payload: nil, options: {})
			self.execute(path: PATHS[:site], http_method: 'post', payload: payload)
		end

	alias_method :sites, :collect_sites
	end
end