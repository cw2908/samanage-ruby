# frozen_string_literal: true

module Samanage
  class Api
    def get_groups(path: PATHS[:group], options: {})
      path = "groups.json?"
      self.execute(path: path, options: options)
    end

    def collect_groups(options: {})
      groups = Array.new
      total_pages = self.get_groups(options: options)[:total_pages]
      1.upto(total_pages) do |page|
        options[:page] = page

        puts "Collecting Groups page: #{page}/#{total_pages}" if options[:verbose]
        path = "groups.json?"
        self.execute(path: path, options: options)[:data].each do |group|
          if block_given?
            yield group
          end
          groups << group
        end
      end
      groups
    end

    def create_group(payload:, options: {})
      self.execute(path: PATHS[:group], http_method: "post", payload: payload)
    end

    def find_group_id_by_name(group: "", options: {})
      options[:name] = group if group && !options.keys.include?(:name)

      path = "groups.json?"
      group_api = self.execute(path: path, options: options)
      # Group names are case sensitive
      if !group_api[:data].empty? && group == group_api[:data].first["name"]
        group_api[:data].first["id"]
      end
    end

    def find_group(id:, options: {})
      path = "groups/#{id}.json"
      self.execute(path: path, options: {})
    end

    def add_member_to_group(email:, group_id: nil, group_name: nil)
      group_id ||= self.find_group_id_by_name(group: group_name)
      user_id = self.find_user_id_by_email(email: email)
      member_path = "memberships.json?group_id=#{group_id}.json&user_ids=#{user_id}"
      self.execute(path: member_path, http_method: "post")
    end

    def delete_group(id:)
      self.execute(path: "groups/#{id}.json", http_method: "delete")
    end

    alias_method :groups, :collect_groups
  end
end
