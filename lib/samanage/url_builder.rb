module Samanage
  class UrlBuilder
    attr_accessor :url
    @url = ''

    def initialize(path: nil,options: nil)
      self.url =  map_path(path: path, options: options)
      return url
    end


    def map_path(path: nil, options: nil)
      url = String.new
      parameters = String.new
      case path
      when /user/
        url += 'users'
      when /hardware/
        url += 'hardwares'
      when /other_asset/
        url += 'other_assets'
      when /incident/
        url += 'incidents'
      when /change/
        url += 'changes'
      when /custom_field/
        url += 'custom_fields'
      when /custom_form/
        url += 'custom_forms'
      when /mobile/
        url += 'mobiles'
      when /site/
        url += 'sites'
      when /department/
        url += 'departments'
      when /contract/
        url += 'contracts'
      when /group/
        url += 'groups'
      end

      if path.match(/(\d)+/)
        url += "/" + path.match(/(\d)+/)[0] + ".json"
        return url
      end

      options.each_pair do |field, value|
        if field.to_s == 'id' && value.to_s.match(/(\d)+/)
          url += "/#{value}.json"
          # Return. Filters not valid on an id
          return url
        end
        sub_param = "?#{field}=#{value}"
        parameters += sub_param + '&'
      end
      url += ".json" + parameters
      return url
    end
  end
end