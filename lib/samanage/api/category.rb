# frozen_string_literal: true

module Samanage
  class Api
    def get_categories(path: PATHS[:category], options: {})
      path = "categories.json"
      self.execute(path: path, options: options)
    end


    # Samanage categories are not paginated
    # - to break into subcategories, add
    def collect_categories(options: {})
      request = self.execute(http_method: "get", path: "categories.json", options: options)
      request[:data]
    end

    def create_category(payload: nil, options: {})
      self.execute(path: PATHS[:category], http_method: "post", payload: payload, options: options)
    end

    def delete_category(id:)
      self.execute(path: "categories/#{id}", http_method: "delete", options: options)
    end

    alias_method :categories, :collect_categories
  end
end
