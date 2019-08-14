# frozen_string_literal: true

module Samanage
  class Api
    def get_solutions(path: PATHS[:solution], options: {})
      path = "solutions.json?"
      self.execute(path: path, options: options)
    end

    def collect_solutions(options: {})
      solutions = Array.new
      total_pages = self.get_solutions(options: options)[:total_pages]
      1.upto(total_pages) do |page|
        options[:page] = page

        puts "Collecting Solutions page: #{page}/#{total_pages}" if options[:verbose]
        path = "solutions.json?"
        self.execute(http_method: "get", path: path, options: options)[:data].each do |solution|
          if block_given?
            yield solution
          end
          solutions << solution
        end
      end
      solutions
    end

    def find_solution(id:, options: {})
      path = "solutions/#{id}.json"
      self.execute(path: path)
    end


    def create_solution(payload:, options: {})
      self.execute(path: PATHS[:solution], http_method: "post", payload: payload)
    end

    def update_solution(id:, payload:, options: {})
      self.execute(path: "solutions/#{id}.json", http_method: "put", payload: payload)
    end

    def delete_solution(id:)
      self.execute(path: "solutions/#{id}.json", http_method: "delete")
    end

    alias_method :solutions, :collect_solutions
  end
end
