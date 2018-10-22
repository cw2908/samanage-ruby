module Samanage
  class Api

    # Default get problem path
    def get_problems(path: PATHS[:problem], options: {})
      params = self.set_params(options: options)
      path = 'problems.json?' + params
      self.execute(path: path)
    end


    # Returns all problems. 
    # Options: 
    #   - audit_archives: true
    #   - layout: 'long'
    def collect_problems(options: {})
      problems = Array.new
      total_pages = self.get_problems(options: options)[:total_pages]
      1.upto(total_pages) do |page|
        options[:page] = page
        params = self.set_params(options: options)
        puts "Collecting problems page: #{page}/#{total_pages}" if options[:verbose]
        path = "problems.json?" + params
        request = self.execute(http_method: 'get', path: path)
        request[:data].each do |problem|
          if block_given?
            yield problem
          end
          problems << problem
        end
      end
      problems
    end


    # Create an problem given json
    def create_problem(payload: nil, options: {})
      self.execute(path: PATHS[:problem], http_method: 'post', payload: payload)
    end

    # Find problem by ID
    def find_problem(id: , options: {})
      path = "problems/#{id}.json"
      if options[:layout] == 'long'
        path += '?layout=long'
      end
      self.execute(path: path)
    end

    # Update an problem given id and json
    def update_problem(payload: , id: , options: {})
      path = "problems/#{id}.json"
      self.execute(path: path, http_method: 'put', payload: payload)
    end

    def delete_problem(id: )
      self.execute(path: "problems/#{id}.json", http_method: 'delete')
    end


  alias_method :problems, :collect_problems
  end
end