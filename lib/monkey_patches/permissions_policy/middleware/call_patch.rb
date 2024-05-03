# frozen_string_literal: true

require "action_dispatch"

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

          def call(env)
            _, headers, = response = @app.call(env)

            return response unless html_response?(headers)
            return response if policy_present?(headers)

            request = ActionDispatch::Request.new(env)

            if (policy = request.permissions_policy)
              headers[PERMISSIONS_POLICY] = policy.build(request.controller_instance, builder: PermissionsPolicyHeader)
              headers[FEATURE_POLICY] = policy.build(request.controller_instance)
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

        module PermissionsPolicyHeader
          MAPPINGS = {
            self: "self",
            none: "",
            all: "*"
          }.freeze

          module_function

          def build(policy, context = nil)
            build_directives(policy, context).compact.join(", ")
          end

          def build_directives(policy, context)
            policy.directives.map do |directive, s|
              sources = apply_mappings(s)
              if sources.is_a?(Array)
                allow_list = build_allow_list(sources, context)
                if allow_list.include?(MAPPINGS[:none])
                  "#{directive}=()"
                elsif allow_list.include?(MAPPINGS[:all])
                  "#{directive}=#{MAPPINGS[:all]}"
                else
                  "#{directive}=(#{allow_list.join(' ')})"
                end
              elsif sources
                directive
              end
            end
          end

          def build_allow_list(sources, context)
            sources.map { |source| resolve_source(source, context) }
          end

          def resolve_source(source, context)
            case source
            when String
              if MAPPINGS.value?(source)
                source
              else
                "\"#{source}\""
              end
            when Symbol
              source.to_s
            when Proc
              raise "Missing context for the dynamic permissions policy source: #{source.inspect}" if context.nil?

              context.instance_exec(&source)

            else
              raise "Unexpected permissions policy source: #{source.inspect}"
            end
          end

          def apply_mappings(sources)
            sources.map do |source|
              case source
              when Symbol
                apply_mapping(source)
              when String, Proc
                source
              else
                raise ArgumentError, "Invalid HTTP permissions policy source: #{source.inspect}"
              end
            end
          end

          def apply_mapping(source)
            MAPPINGS.fetch(source) do
              raise ArgumentError, "Unknown HTTP permissions policy source mapping: #{source.inspect}"
            end
          end
        end
      end
    end
  end
end

MonkeyPatches::PermissionsPolicy::Middleware::CallPatch.apply_patch
