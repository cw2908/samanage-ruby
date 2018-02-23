require 'open-uri'
require 'fileutils'
module Samanage
  class Api
    def send_activation_email(email: )
      user_id = self.find_user_id_by_email(email: email)
      raise Samanage::Error.new(error: 'Invalid Email', response: {}) unless user_id
      self.execute(http_method: 'put', path: "users/#{user_id}.json?send_activation_email=1&add_callbacks=1")
    end

    # Downloads a Samanage Attachment object can overwrite default filename and path (Object/ObjectID/Original_Filename)
    def download_attachment(attachment: {}, filename: nil, path: nil)
      attachable_type = attachment['attachable_type']
      attachable_id = attachment['attachable_id'].to_s
      filename = filename || attachment['filename']
      url = attachment['url']
      
      file_path = path ?  path : File.join(Dir.pwd,attachable_type,attachable_id)
      unless File.directory?(file_path)
        FileUtils.mkpath(file_path)
      end
      
      exact_path = File.join(file_path,filename)
      downloaded_attachment = open(exact_path, "wb+") do |file|
        file << open(url).read
      end
      downloaded_attachment
    end
  end
end