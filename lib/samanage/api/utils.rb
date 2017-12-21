module Samanage
  class Api
    def self.send_ativation_email(email: )
      user_id = self.find_user_id_by_email(email: email)
      self.execute(path: "users/#{user_id}.json?send_activation_email=1&add_callbacks=1")
    end
  end
end