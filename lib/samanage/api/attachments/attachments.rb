module Samanage
  class Api
    class Attachment
      include HTTMultiParty
      def upload_attachment(attachment: , attachable_id: , attachable_type: )
        if attachment.class != File
          return "Attachment argument must be file, received: #{attachment.class} for #{attachment}"
        end
        # self.execute(
        #   path: 'attachments.json',
        #   http_method: 'post',
        #   headers: {'Content-Type' => "multipart/form-data"},
        #   payload: {
        #     'file[attachment]' => attachment,
        #     'file[attachable_id]' => attachable_id,
        #     'file[attachable_type]' => attachable_type,
        #   }
        # )
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
end