# frozen_string_literal: true

require "action_dispatch"
require_relative "../../../middleware/builders/permissions_policy_header"

module MonkeyPatches
  module PermissionsPolicy
    module Middleware
      module CallPatch
        class << self
          EXPIRATION_DATE = Date.new(2024, 8, 15)

          def apply_patch
            if Date.today > EXPIRATION_DATE
              puts "WARNING: Please re-evaluate whether or not the "\
                     "ActionDispatch::PermissionsPolicy::Middleware call"\
                     "patch present in #{__FILE__} is still necessary."
            end

            const = find_const
            mtd = find_method(const)

            # make sure the class we want to patch exists;
            # make sure the #call method exists and accepts exactly
            # one argument
            unless const && mtd && mtd.arity == 1
              raise "Could not find class or method when patching "\
                      "ActionDispatch::PermissionsPolicy::Middleware's"\
                      "call method. Please investigate."
            end

            # if rails has been upgraded, make sure this patch is still
            # necessary
            unless rails_version_ok?
              puts "WARNING: It looks like Rails has been upgraded since "\
                     "ActionDispatch::PermissionsPolicy::Middleware's call method"\
                     "was monkeypatched in #{__FILE__}. Please re-evaluate the patch."
            end

            # actually apply the patch
            const.prepend(InstanceMethods)
          end

          private

          def find_const
            Kernel.const_get("ActionDispatch::PermissionsPolicy::Middleware")
          rescue NameError
            # return nil if the constant doesn't exist
          end

          def find_method(const)
            return unless const

            const.instance_method(:call)
          rescue NameError
            # return nil if the constant doesn't exist
          end

          def rails_version_ok?
            Rails::VERSION::MAJOR == 7 && Rails::VERSION::MINOR == 1
          end
        end

        module InstanceMethods
          CONTENT_TYPE       = "Content-Type"
          # The Feature-Policy header has been renamed to Permissions-Policy.
          # Since the Permissions-Policy isn't yet supported by all browsers,
          # this middleware inserts both headers. For now `POLICY` still refers
          # to the old header name. This will change in the future, when
          # Permissions-Policy is supported by all browsers.
          FEATURE_POLICY     = "Feature-Policy"
          PERMISSIONS_POLICY = "Permissions-Policy"
          PERMISSIONS_POLICY_HEADER = ::Middleware::Builders::PermissionsPolicyHeader.new
          FEATURE_POLICY_HEADER = ::Middleware::Builders::FeaturePolicyHeader.new

          private_constant :PERMISSIONS_POLICY_HEADER, :FEATURE_POLICY_HEADER

          def call(env)
            _, headers, = response = @app.call(env)

            return response unless html_response?(headers)
            return response if policy_present?(headers)

            request = ActionDispatch::Request.new(env)

            if (policy = request.permissions_policy)
              headers[PERMISSIONS_POLICY] =
                policy.build(request.controller_instance, builder: PERMISSIONS_POLICY_HEADER)
              headers[FEATURE_POLICY] = policy.build(request.controller_instance, builder: FEATURE_POLICY_HEADER)
            end

            if policy_empty?(policy)
              headers.delete(PERMISSIONS_POLICY)
              headers.delete(FEATURE_POLICY)
            end

            response
          end

          class << self
            private

            def html_response?(headers)
              return unless (content_type = headers[CONTENT_TYPE])

              content_type.include?("html")
            end

            def policy_present?(headers)
              headers[PERMISSIONS_POLICY] || headers[FEATURE_POLICY]
            end

            def policy_empty?(policy)
              policy&.directives&.empty?
            end
          end
        end
      end
    end
  end
end

MonkeyPatches::PermissionsPolicy::Middleware::CallPatch.apply_patch
