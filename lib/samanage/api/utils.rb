require 'open-uri'
require 'fileutils'

# API Utils
module Samanage
  class Api
    def send_activation_email(email: )
      user_id = self.find_user_id_by_email(email: email)
      raise Samanage::Error.new(error: 'Invalid Email', response: {}) unless user_id
      options = {
        send_activation_email: 1,
        add_callbacks: 1
      }
      self.execute(http_method: 'put', path: "users/#{user_id}.json", options: options)
    end

    def find_name_from_group_id(group_id: )
      return if [-1,'-1',nil,''].include?(group_id)
      begin
        self.find_group(id: group_id).to_h.dig(:data,'name')
      rescue => e
        return "[#{e.class}]: #{e.inspect} Unable to find user for group id #{group_id}"
      end
    end
  end
end