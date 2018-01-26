module Samanage
	class Api
		def get_sites(path: PATHS[:site], options: {})
			url = Samanage::UrlBuilder.new(path: path, options: options).url
			self.execute(path: url)
		end

		def collect_sites(options: {})
			page = 1
			sites = Array.new
			total_pages = self.get_sites[:total_pages]
			1.upto(total_pages) do |page|
				puts "Collecting Sites page: #{page}/#{total_pages}" if options[:verbose]
				sites += self.execute(http_method: 'get', path: "sites.json?page=#{page}")[:data]
			end
			sites
		end

		def create_site(payload: nil, options: {})
			self.execute(path: PATHS[:site], http_method: 'post', payload: payload)
		end

		def delete_site(id: )
			self.execute(path: "sites/#{id}.json", http_method: 'delete')
		end

	alias_method :sites, :collect_sites
	end
end