require "sinatra/base"

module Sinatra
  module Cors
    module Helpers
      def cors
        if is_cors_request?
          if is_preflight_request?
            unless method_is_allowed?
              logger.warn bad_method_message
              return
            end
            unless headers_are_allowed?
              logger.warn bad_headers_message
              return
            end

            response.headers["Access-Control-Allow-Headers"] = request.env["HTTP_ACCESS_CONTROL_REQUEST_HEADERS"]
            response.headers["Access-Control-Allow-Methods"] = request.env["HTTP_ACCESS_CONTROL_REQUEST_METHOD"]
            response.headers["Access-Control-Max-Age"] = settings.max_age if settings.max_age?
          else
            response.headers["Access-Control-Expose-Headers"] = settings.expose_headers if settings.expose_headers?
          end

          if origin_is_allowed?
            response.headers["Access-Control-Allow-Origin"] = request.env["HTTP_ORIGIN"]
          else
            logger.warn bad_origin_message
            response.headers["Access-Control-Allow-Origin"] = "null"
          end
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

      private

      def bad_method_message
        "This CORS preflight request was rejected because the client is asking permission to make a \
'#{request.env["HTTP_ACCESS_CONTROL_REQUEST_METHOD"]}' request, but the server only allows \
'#{settings.allow_methods}' requests.  To allow the server to respond to this request method, add it \
to the `allow_methods` sinatra setting."
      end

      def bad_headers_message
        "This CORS preflight request was rejected because the client is asking permission to make a \
request with the headers '#{request.env["HTTP_ACCESS_CONTROL_REQUEST_HEADERS"]}', but the server \
only allows requests with the headers '#{settings.allow_headers}'.  To allow the server to respond \
to requests with these headers, you can add them to the `allow_headers` sinatra setting."
      end

      def bad_origin_message
        "This CORS request was rejected because the client is making the request from '#{request.env["HTTP_ORIGIN"]}', but the server only allows requests from '#{settings.allow_origin}'.  To allow the server to respond to requests from this origin, you can add it to the `allow_origin` sinatra setting."
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
        response.headers["Allow"] = settings.allow_methods || ""
      end

      app.after do
        cors
      end
    end
  end
end
