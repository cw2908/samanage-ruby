require 'open-uri'
require 'fileutils'
module Samanage
  class Api
    def send_activation_email(email: )
      user_id = self.find_user_id_by_email(email: email)
      raise Samanage::Error.new(error: 'Invalid Email', response: {}) unless user_id
      puts "user_id: #{user_id}"
      self.execute(http_method: 'put', path: "users/#{user_id}.json?send_activation_email=1&add_callbacks=1")
    end
  end
end