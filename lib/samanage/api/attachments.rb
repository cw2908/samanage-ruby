module Samanage
  class Api
    include HTTPMultiParty
    def upload_attachment(attachment: , attachable_id: , attachable_type: )
      self.execute(
        path: 'webhooks',
        http_method: 'post',
        headers: {
          'Accept' => "application/vnd.samanage.v2.0+#{self.content_type}#{verbose}",
          'Content-Type' => "multipart/form-data",
          'X-Samanage-Authorization' => 'Bearer ' + self.token
        },
        payload: {
          'file[attachment]' => attachment,
          'file[attachable_id]' => attachable_id,
          'file[attachable_type]' => attachable_type,
        }
      )
    end
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