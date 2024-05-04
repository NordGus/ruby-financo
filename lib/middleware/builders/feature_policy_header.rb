# frozen_string_literal: true

module Middleware
  module Builders
    class FeaturePolicyHeader
      MAPPINGS = {
        self: "'self'",
        none: "'none'",
        all: "*"
      }.freeze

      private_constant :MAPPINGS

      def build(policy, context = nil)
        build_directives(policy, context).compact.join("; ")
      end

      private

      def build_directives(policy, context)
        policy.directives.map do |directive, s|
          sources = apply_mappings(s)
          if sources.is_a?(Array)
            allow_list = build_allow_list(sources, context)
            if allow_list.include?(MAPPINGS[:none])
              "#{directive} #{MAPPINGS[:none]}"
            elsif allow_list.include?(MAPPINGS[:all])
              "#{directive} #{MAPPINGS[:all]}"
            else
              "#{directive} #{allow_list.join(' ')}"
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
          source
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
