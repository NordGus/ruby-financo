# frozen_string_literal: true

require_relative "builders/permissions_policy_header"

module Middleware
  class PermissionsPolicy
    class Policy
      # TODO: change to actual permissions values
      # List of available permissions can be found at
      # https://github.com/w3c/webappsec-permissions-policy/blob/main/features.md#policy-controlled-features
      DIRECTIVES = {
        accelerometer: "accelerometer",
        ambient_light_sensor: "ambient-light-sensor",
        autoplay: "autoplay",
        camera: "camera",
        encrypted_media: "encrypted-media",
        fullscreen: "fullscreen",
        geolocation: "geolocation",
        gyroscope: "gyroscope",
        hid: "hid",
        idle_detection: "idle_detection",
        magnetometer: "magnetometer",
        microphone: "microphone",
        midi: "midi",
        payment: "payment",
        picture_in_picture: "picture-in-picture",
        screen_wake_lock: "screen-wake-lock",
        serial: "serial",
        sync_xhr: "sync-xhr",
        usb: "usb",
        web_share: "web-share"
      }.freeze

      SOURCES = %i[none all self].freeze

      private_constant :DIRECTIVES, :SOURCES

      DIRECTIVES.each do |name, directive|
        define_method(name) do |*sources|
          if sources.first && validate_sources(sources)
            @directives[directive] = sources
          else
            @directives.delete(directive)
          end
        end
      end

      %w[speaker vibrate vr].each do |directive|
        define_method(directive) do |*sources|
          ActionDispatch.deprecator.warn(<<~MSG)
            The `#{directive}` permissions policy directive is deprecated
            and will be removed in Rails 7.2.

            There is no browser support for this directive, and no plan
            for browser support in the future. You can just remove this
            directive from your application.
          MSG

          if sources.first && validate_sources(sources)
            @directives[directive] = sources
          else
            @directives.delete(directive)
          end
        end
      end

      attr_reader :directives

      def initialize
        @directives = {}
        yield self if block_given?
      end

      private

      def validate_sources(sources)
        sources.map do |source|
          case source
          when Symbol
            unless SOURCES.include?(source)
              raise ArgumentError, "Unknown HTTP permissions policy source mapping: #{source.inspect}"
            end
          when String, Proc
            true
          else
            raise ArgumentError, "Invalid HTTP permissions policy source: #{source.inspect}"
          end
        end
      end
    end

    HEADER = "permissions-policy"

    private_constant :HEADER

    def initialize(app, &block)
      @app = app
      @header_builder = Builders::PermissionsPolicyHeader.new
      @policy = Policy.new(&block)
    end

    def call(env)
      _, headers, = response = @app.call(env)

      return response unless html_response?(headers)
      return response if policy_present?(headers)

      request = ActionDispatch::Request.new(env)

      headers[HEADER] = @header_builder.build(@policy, request.controller_instance)

      headers.delete(HEADER) if policy_empty?

      response
    end

    private

    def html_response?(headers)
      return false unless (content_type = headers[Rack::CONTENT_TYPE])

      content_type.include?("html")
    end

    def policy_present?(headers)
      headers[HEADER]
    end

    def policy_empty?
      @policy&.directives&.empty?
    end
  end
end
