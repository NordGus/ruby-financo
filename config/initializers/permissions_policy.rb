# frozen_string_literal: true

require_relative "../../lib/middleware/permissions_policy"

# Be sure to restart your server when you modify this file.

# Define an application-wide HTTP permissions policy. For further
# information see: https://developers.google.com/web/updates/2018/06/feature-policy

# Old/Legacy Feature-Policy
Rails.application.config.permissions_policy do |policy|
  policy.camera      :none
  policy.gyroscope   :none
  policy.microphone  :none
  policy.usb         :none
  policy.fullscreen  :self
  policy.payment     :self, "https://secure.example.com"
  policy.vr          :none
end

Rails.application.middleware.use Middleware::PermissionsPolicy do |policy|
  policy.camera      :none
  policy.gyroscope   :none
  policy.microphone  :none
  policy.usb         :all
  policy.fullscreen  :self
  policy.payment     :self, "https://secure.example.com"
  policy.vr          :none
end
