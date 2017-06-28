require "sinatra/base"

module Sinatra
  module Cors
    module Helpers
      def cors
        if is_cors_request?
          if is_preflight_request?
            return unless method_is_allowed? && headers_are_allowed?

            response.headers["Access-Control-Allow-Headers"] = request.env["HTTP_ACCESS_CONTROL_REQUEST_HEADERS"]
            response.headers["Access-Control-Allow-Methods"] = request.env["HTTP_ACCESS_CONTROL_REQUEST_METHOD"]
            response.headers["Access-Control-Max-Age"] = settings.max_age if settings.max_age?
          else
            response.headers["Access-Control-Expose-Headers"] = settings.expose_headers if settings.expose_headers?
          end

          response.headers["Access-Control-Allow-Origin"] = origin_is_allowed? ? request.env["HTTP_ORIGIN"] : "null"
          response.headers["Access-Control-Allow-Credentials"] = settings.allow_credentials.to_s if settings.allow_credentials?
        end
      end

      def is_cors_request?
        request.env.has_key? "HTTP_ORIGIN"
      end

      def is_preflight_request?
        request.env["REQUEST_METHOD"] == "OPTIONS"
      end

      def method_is_allowed?
        allow_methods = settings.allow_methods || response.headers["Allow"] || ""
        request_method = request.env["HTTP_ACCESS_CONTROL_REQUEST_METHOD"] || ""
        allow_methods.split.include? request_method
      end

      def headers_are_allowed?
        allow_headers = settings.allow_headers || ""
        request_headers = request.env["HTTP_ACCESS_CONTROL_REQUEST_HEADERS"] || ""
        diff = request_headers.split - allow_headers.split
        diff.size == 0
      end

      def origin_is_allowed?
        settings.allow_origin == "*" || settings.allow_origin.split.include?(request.env["HTTP_ORIGIN"])
      end
    end

    def self.registered(app)
      app.helpers Cors::Helpers

      app.disable :allow_origin
      app.disable :allow_methods
      app.disable :allow_headers
      app.disable :max_age
      app.disable :expose_headers
      app.disable :allow_credentials

      app.set(:is_cors_preflight) { |bool|
        condition { is_cors_request? && is_preflight_request? == bool }
      }

      app.options "*", is_cors_preflight: true do
        response.headers["Allow"] = settings.allow_methods if settings.allow_methods?
      end

      app.after do
        cors
      end
    end
  end
end
