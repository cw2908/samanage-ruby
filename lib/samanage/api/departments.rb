module Samanage
  class Api
    def get_departments(path: PATHS[:department], options: {})
      params = self.set_params(options: options)
      path = 'departments.json?' + params
      self.execute(path: path)
    end

    def collect_departments(options: {})
      departments = Array.new
      total_pages = self.get_departments(options: options)[:total_pages]
      1.upto(total_pages) do |page|
        options[:page] = page
        params = self.set_params(options: options)
        puts "Collecting Departments page: #{page}/#{total_pages}" if options[:verbose]
        path = "departments.json?#{params}"
        self.execute(path: path)[:data].each do |department|
          if block_given?
            yield department
          end
          departments << department
        end
      end
      departments
    end

    def create_department(payload: , options: {})
      self.execute(path: PATHS[:department], http_method: 'post', payload: payload)

    end
    def delete_department(id: )
      self.execute(path: "departments/#{id}.json", http_method: 'delete')
    end

    alias_method :departments, :collect_departments
  end
end