# frozen_string_literal: true

module Samanage
  class Api
    def download_attachment(attachment: {}, filename: nil, path: nil)
      attachable_type = attachment["attachable_type"]
      attachable_id = attachment["attachable_id"].to_s
      filename ||= attachment["filename"]
      url = attachment["url"]

      file_path = path || File.join(Dir.pwd, attachable_type, attachable_id)
      FileUtils.mkpath(file_path) unless File.directory?(file_path)

      exact_path = File.join(file_path, filename)
      downloaded_attachment = File.open(exact_path, "wb+") do |file|
        file << URI.parse(url).read
      end
      downloaded_attachment
    end

    def create_attachment(filepath:, attachable_type:, attachable_id:)
      unless File.exist?(filepath)
        puts "Cannot find filepath: '#{filepath.inspect}'"
        return
      end
      req = execute(
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
      req
    end
  end
end
