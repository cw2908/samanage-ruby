# frozen_string_literal: true

module Samanage
  class Api
    def get_tasks(path: PATHS[:task], options: {})
      path = "tasks.json?"
      self.execute(path: path, options: options)
    end

    def collect_tasks(options: {})
      tasks = Array.new
      total_pages = self.get_tasks(options: options)[:total_pages]
      1.upto(total_pages) do |page|
        options[:page] = page

        puts "Collecting tasks page: #{page}/#{total_pages}" if options[:verbose]
        path = "tasks.json?"
        self.execute(path: path, options: options)[:data].each do |task|
          if block_given?
            yield task
          end
          tasks << task
        end
      end
      tasks
    end

    def create_task(incident_id:, payload:, options: {})
      path = "incidents/#{incident_id}/tasks.json"
      self.execute(path: path, http_method: "post", payload: payload)
    end

    def delete_task(incident_id:, task_id:)
      self.execute(path: "incidents/#{incident_id}/tasks/#{task_id}.json", http_method: "delete")
    end

    alias_method :tasks, :collect_tasks
  end
end
