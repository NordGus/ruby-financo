# frozen_string_literal: true

require_relative "../../../lib/middleware/builders/feature_policy_header"

module MonkeyPatches
  module PermissionsPolicy
    # = MonkeyPatches::PermissionsPolicy::BuildPatch
    # This patch is no longer in use
    module BuildPatch
      class << self
        EXPIRATION_DATE = Date.new(2024, 8, 15)

        def apply_patch
          if Date.today > EXPIRATION_DATE
            puts "WARNING: Please re-evaluate whether or not the "\
                   "ActionDispatch::PermissionsPolicy build"\
                   "patch present in #{__FILE__} is still necessary."
          end

          const = find_const
          mtd = find_method(const)

          # make sure the class we want to patch exists;
          # make sure the #build method exists and accepts exactly
          # one nillable argument
          unless const && mtd && mtd.arity == -1
            raise "Could not find class or method when patching "\
                    "ActionDispatch::PermissionsPolicy's build method."\
                    "Please investigate."
          end

          # if rails has been upgraded, make sure this patch is still
          # necessary
          unless rails_version_ok?
            puts "WARNING: It looks like Rails has been upgraded since "\
                   "ActionDispatch::PermissionsPolicy's build method"\
                   "was monkeypatched in #{__FILE__}. Please re-evaluate the patch."
          end

          # actually apply the patch
          const.prepend(InstanceMethods)
        end

        private

        def find_const
          Kernel.const_get("ActionDispatch::PermissionsPolicy")
        rescue NameError
          # return nil if the constant doesn't exist
        end

        def find_method(const)
          return unless const

          const.instance_method(:build)
        rescue NameError
          # return nil if the constant doesn't exist
        end

        def rails_version_ok?
          Rails::VERSION::MAJOR == 7 && Rails::VERSION::MINOR == 1
        end
      end

      module InstanceMethods
        def build(context = nil, builder: nil)
          if builder
            builder.build(self, context)
          else
            super(context)
          end
        end
      end
    end
  end
end

MonkeyPatches::PermissionsPolicy::BuildPatch.apply_patch
