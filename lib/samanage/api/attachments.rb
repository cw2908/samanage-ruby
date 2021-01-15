# frozen_string_literal: true

module Samanage
  class Api
    # This takes the attachment as seen in the array found in [id].json?layout=long requests +optional filename and path for saving
    def download_attachment(attachment: {}, filename: nil, path: nil)
      attachable_type = attachment["attachable_type"]
      attachable_id = attachment["attachable_id"].to_s
      filename ||= attachment["filename"]
      url = attachment["url"]

      default_path = File.join(Dir.pwd, attachable_type, attachable_id)
      file_path = path || default_path
      FileUtils.mkpath(file_path) unless File.directory?(file_path)

      exact_path = File.join(file_path, filename)
      downloaded_attachment = File.open(exact_path, "wb+") do |file|
        file << URI.parse(url).read
      end
    end

    # send http request as multipart form-data. file[attachment] is file object
    def create_attachment(filepath:, attachable_type:, attachable_id:)
      unless File.exist?(filepath)
        puts "Cannot find filepath: '#{filepath.inspect}'"
        return
      end
      execute(
        path: "attachments.json",
        http_method: "post",
        multipart: true,
        payload: {
          "file[attachable_type]" => attachable_type,
          "file[attachable_id]" => attachable_id,
          "file[attachment]" => File.open(filepath, "rb")
        },
        headers: {
          "Content-Type" => "multipart/form-data",
          "X-Samanage-Authorization" => "Bearer " + token
        }
      )
    end
  end
end
