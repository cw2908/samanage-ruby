module Samanage
  class Api
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