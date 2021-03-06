# frozen_string_literal: true

$LOAD_PATH << File.dirname(__FILE__)
require "httparty"

require "samanage/api"
require "samanage/api/attachments"
require "samanage/api/category"
require "samanage/api/changes"
require "samanage/api/comments"
require "samanage/api/configuration_items"
require "samanage/api/contracts"
require "samanage/api/custom_fields"
require "samanage/api/custom_forms"
require "samanage/api/departments"
require "samanage/api/groups"
require "samanage/api/hardwares"
require "samanage/api/incidents"
require "samanage/api/mobiles"
require "samanage/api/other_assets"
require "samanage/api/problems"
require "samanage/api/purchase_orders"
require "samanage/api/releases"
require "samanage/api/requester"
require "samanage/api/sites"
require "samanage/api/solutions"
require "samanage/api/tasks"
require "samanage/api/time_tracks"
require "samanage/api/users"
require "samanage/api/utils"
require "samanage/api/vendors"
require "samanage/error"
require "samanage/language"
require "samanage/url_builder"
require "samanage/version"

module Samanage
end

class Hash
  def except!(*keys)
    keys.each { |key| delete(key) }
    self
  end
  def except(*keys)
    dup.except!(*keys)
  end
end
