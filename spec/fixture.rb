require "sinatra"
require "./lib/sinatra/cors"

get "/foo/:id" do
  "foo"
end

delete "/foo/:id" do
  "foo"
end

post "/bar/:id" do
  "bar"
end

register Sinatra::Cors

set :allow_origin, "http://example.com http://foo.com"
set :allow_methods, "GET HEAD POST"
set :allow_headers, "content-type if-modified-since"
