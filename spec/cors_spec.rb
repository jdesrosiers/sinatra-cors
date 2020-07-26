ENV["RACK_ENV"] = "test"

require "rspec"
require "rack/test"
require "fixture"

RSpec.describe "Sinatra.Cors" do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  describe "A non-CORS OPTIONS request" do
    it "should not be handled" do
      options "/foo/1"
      expect(last_response).to be_not_found
    end
  end

  describe "A CORS preflight request for a route that doesn't exist" do
    it "should 404" do
      rack_env = {
        "HTTP_ORIGIN" => "http://example.com",
        "HTTP_ACCESS_CONTROL_REQUEST_METHOD" => "GET",
      }
      options "/baz/1", {}, rack_env
      expect(last_response).to be_not_found
    end
  end

  describe "A CORS preflight with invalid method" do
    before :all do
      rack_env = {
        "HTTP_ORIGIN" => "http://example.com",
        "HTTP_ACCESS_CONTROL_REQUEST_METHOD" => "DELETE",
      }
      options "/foo/1", {}, rack_env
    end

    it "should not return an Access-Control-Allow-Origin header" do
      assert_no_access_control_headers
    end
  end

  describe "A valid CORS preflight request" do
    describe "with an Access-Control-Request-Headers header" do
      before :all do
        rack_env = {
          "HTTP_ORIGIN" => "http://example.com",
          "HTTP_ACCESS_CONTROL_REQUEST_METHOD" => "GET",
          "HTTP_ACCESS_CONTROL_REQUEST_HEADERS" => "if-modified-since"
        }
        options "/foo/1", {}, rack_env
      end

      it "should be handled for all routes" do
        expect(last_response).to be_ok
      end

      it "should have an Allow header build from existing routes" do
        expect(last_response["Allow"]).to eq("OPTIONS,GET,HEAD,DELETE")
      end

      it "should have an Access-Control-Allow-Methods header that includes only the method requested" do
        expect(last_response["Access-Control-Allow-Methods"]).to eq("GET")
      end

      it "should have an Access-Control-Allow-Origin header that includes only the origin of the request" do
        expect(last_response["Access-Control-Allow-Origin"]).to eq("http://example.com")
      end

      it "should have an Access-Control-Allow-Headers header that includes only the headers requested" do
        expect(last_response["Access-Control-Allow-Headers"]).to eq("if-modified-since")
      end
    end

    describe "without an Access-Control-Request-Headers header" do
      before :all do
        rack_env = {
          "HTTP_ORIGIN" => "http://example.com",
          "HTTP_ACCESS_CONTROL_REQUEST_METHOD" => "GET"
        }
        options "/foo/1", {}, rack_env
      end

      it "should not have an Access-Control-Allow-Headers header" do
        expect(last_response.has_header? "Access-Control-Allow-Headers").to eq(false)
      end
    end
  end

  describe "The Access-Control-Max-Age header" do
    after :all do
      app.disable :max_age
    end

    it "should be set to the value of the :max_age setting" do
      app.set :allow_origin, "http://example.com"
      app.set :max_age, "600"
      rack_env = {
        "HTTP_ORIGIN" => "http://example.com",
        "HTTP_ACCESS_CONTROL_REQUEST_METHOD" => "GET",
      }
      options "/foo/1", {}, rack_env

      expect(last_response["Access-Control-Max-Age"]).to eq("600")
    end
  end

  describe "A CORS actual request" do
    before :all do
      rack_env = {
        "HTTP_ORIGIN" => "http://example.com",
      }
      get "/foo/1", {}, rack_env
    end

    it "should have an Access-Control-Allow-Origin header that includes only the origin of the request" do
      expect(last_response["Access-Control-Allow-Origin"]).to eq("http://example.com")
    end
  end

  describe "The Access-Control-Allow-Origin header" do
    before :all do
      @allow_origin = app.settings.allow_origin
    end
    after :all do
      app.set :allow_origin, @allow_origin
    end

    def make_request(allow_origin)
      app.set :allow_origin, allow_origin
      rack_env = {
        "HTTP_ORIGIN" => "http://example.com",
      }
      get "/foo/1", {}, rack_env
    end

    it "should have no access control headers if the origin is not allowed" do
      make_request("http://bar.com")
      assert_no_access_control_headers
    end

    it "should have no access control headers if none of the origins are allowed" do
      make_request("http://foo.com http://bar.com")
      assert_no_access_control_headers
    end

    it "should allow any origin if :allow_origin is '*'" do
      make_request("*")
      expect(last_response["Access-Control-Allow-Origin"]).to eq("http://example.com")
    end

    it "should allow regexps on the :allow_origin option" do
      make_request(/.*example.com/)
      expect(last_response["Access-Control-Allow-Origin"]).to eq("http://example.com")
    end

    it "should allow multiple types on the :allow_origin option" do
      make_request([/not-a-match/, "notamatch.com", /.*/])
      expect(last_response["Access-Control-Allow-Origin"]).to eq("http://example.com")
    end
  end

  describe "The Access-Control-Allow-Credentials header" do
    after :all do
      app.disable :allow_credentials
    end

    it "should be 'true' if :allow_credentials is true" do
      app.set :allow_credentials, true
      rack_env = {
        "HTTP_ORIGIN" => "http://example.com",
      }
      get "/foo/1", {}, rack_env

      expect(last_response["Access-Control-Allow-Credentials"]).to eq("true")
    end
  end

  describe "The Access-Control-Expose-Headers header" do
    after :all do
      app.disable :expose_headers
    end

    it "should be set to the value of the :expose_headers setting" do
      app.set :expose_headers, "location,link"
      rack_env = {
        "HTTP_ORIGIN" => "http://example.com",
      }
      get "/foo/1", {}, rack_env

      expect(last_response["Access-Control-Expose-Headers"]).to eq("location,link")
    end
  end

  def assert_no_access_control_headers
      expect(last_response["Access-Control-Allow-Origin"]).to eq(nil)
      expect(last_response["Access-Control-Allow-Header"]).to eq(nil)
      expect(last_response["Access-Control-Allow-Methods"]).to eq(nil)
      expect(last_response["Access-Control-Max-Age"]).to eq(nil)
      expect(last_response["Access-Control-Expose-Headers"]).to eq(nil)
      expect(last_response["Access-Control-Allow-Credentials"]).to eq(nil)
  end
end
