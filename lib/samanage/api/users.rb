module Samanage
  class Api

  # Get users, using URL builder
  def get_users(path: PATHS[:user], options: {})
    
    path = 'users.json?'
    self.execute(path: path, options: options)
  end

  # Returns all users in the account
    def collect_users(options: {})
      users = Array.new
      total_pages = self.get_users(options: options)[:total_pages]
      1.upto(total_pages) do |page|
        options[:page] = page
        
        path = "users.json?"
        puts "Collecting Users page: #{page}/#{total_pages}" if options[:verbose]
        path = "users.json?"
        self.execute(path: path, options: options)[:data].each do |user|
          if block_given?
            yield user
          end
          users << user
        end
      end
      users
    end

    # Create user given JSON
    def create_user(payload: , options: {})
      self.execute(path: PATHS[:user], http_method: 'post', payload: payload)
    end

    # Return user by ID
    def find_user(id: , options: {})
      path = "users/#{id}.json"
      self.execute(path: path, options: {})
    end

    # Email is unique so compare first for exact match only. Returns nil or the id
    def find_user_id_by_email(email: )
      api_call = self.get_users(options: {email: email})
      api_call[:data]
        .select{|u| u['email'].to_s.downcase == email.to_s.downcase}
        .first.to_h['id']
    end

    # Returns nil if no matching group_id
    def find_user_group_id_by_email(email: )
      user = self.check_user(value: email)
      group_ids = user[:data].select{|u| u['email'].to_s.downcase == email.to_s.downcase}.first.to_h['group_ids'].to_a
      group_ids.each do |group_id|
        group = self.find_group(id: group_id)
        if group[:data]['is_user'] && email.to_s.downcase == group[:data]['email'].to_s.downcase
          return group_id
        end
      end
      return nil
    end

    # Check for user by field (ex: users.json?field=value)
    def check_user(field: 'email', value: , options: {})
      if field.to_s.downcase == 'email'
        value = value.to_s.gsub("+",'%2B')
      end
      url = "users.json?#{field}=#{value}"
      self.execute(path: url)
    end

    # Update user by id
    def update_user(payload: , id: )
      path = "users/#{id}.json"
      self.execute(path: path, http_method: 'put', payload: payload)
    end

    def delete_user(id: )
      self.execute(path: "users/#{id}.json", http_method: 'delete')
    end

  alias_method :users, :collect_users
  end
end