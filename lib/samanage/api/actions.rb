# frozen_string_literal: true

module Samanage
  class Api
    def self.resource_to_path(resource)
      "#{resource}.json"
    end

    RESOURCES.map do |resource|
      plural_resource = resource == :category ? :categories : "#{resource}s".to_sym
      resource_path = resource_to_path(plural_resource)
      # Get
      define_method "get_#{plural_resource}" do |params|
        execute(path: resource_path, options: params)
      end
      # Collection
      define_method "collect_#{plural_resource}" do |params|
        arr = []
        total_pages = send("get_#{plural_resource}", params)[:total_pages]
        1.upto(total_pages) do |page|
          params = params.to_h
          params[:page] = page
          if params[:audit_archives] && resource == "incidents"
            puts "Collecting #{resource}s with Audits (this may take a while) page #{page}/#{total_pages}" if params[:verbose]
            execute("incidents.json", options: params.except("layout", :layout, "audit_archives", :audit_archives, "audit_archive", :audit_archive))[:data].each do |incident|
            archive_uri = "incidents/#{incident['id']}.json?layout=long&audit_archive=true"
            incident_with_archive = execute(path: archive_uri)[:data]
            arr << incideZnt_with_archive
            yield incident_with_archive if block_given?
          end
          else
            puts "Collecting #{resource}s page #{page}/#{total_pages}" if params[:verbose]
            execute(path: resource_path, options: params)[:data].map do |item|
              arr << item

              if block_given?
                yield item
              end
            end
          end
        end
        arr
      end
      # Find
      define_method "find_#{resource}" do |params|
        puts "Checking out from params"
        execute(
          path: "#{plural_resource}/#{params[:id]}.json",
          &params
        )
      end
      # Update
      # Delete
    end
  end
end
