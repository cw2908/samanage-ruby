# frozen_string_literal: true

# Consts and common lookup functions
module Samanage
  def find_custom_field(custom_fields_values:, field_name:, user_type: false, user_resolve: "email")
    result = custom_fields_values.select { |field| field["name"] == field_name }.first.to_h
    if user_type
      if user_resolve == "email"
        result_value = result.dig("user", "email")
      else
        result_value = result.dig("user", "name")
      end
    else
      result_value = result.dig("value")
    end
    return if [-1, "-1", nil, "", {}].include?(result_value)
    result_value
  end
end
