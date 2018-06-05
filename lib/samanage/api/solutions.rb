module Samanage
  class Api
    def get_solutions(path: PATHS[:solution], options: {})
      url = Samanage::UrlBuilder.new(path: path, options: options).url
      self.execute(path: url)
    end

    def collect_solutions(options: {})
      solutions = Array.new
      total_pages = self.get_solutions[:total_pages]
      1.upto(total_pages) do |page|
        options[:page] = page
        params = self.set_params(options: options)
        puts "Collecting Solutions page: #{page}/#{total_pages}" if options[:verbose]
        path = "solutions.json?" + params
        self.execute(http_method: 'get', path: path)[:data].each do |solution|
          if block_given?
            yield solution
          end
          solutions << solution
        end
      end
      solutions
    end

    def create_solution(payload: , options: {})
      self.execute(path: PATHS[:solution], http_method: 'post', payload: payload)
    end
    
    def update_solution(id: ,payload: , options: {})
      self.execute(path: "solutions/#{id}.json", http_method: 'put', payload: payload)
    end

    def delete_solution(id: )
      self.execute(path: "solutions/#{id}.json", http_method: 'delete')
    end

  alias_method :solutions, :collect_solutions
  end
end