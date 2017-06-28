require "sinatra"
require "./lib/sinatra/cors"

get "/foo" do
  "foo"
end

register Sinatra::Cors

set :allow_origin, "http://example.com http://foo.com"
set :allow_methods, "GET HEAD POST"
set :allow_headers, "content-type if-modified-since"
