[![Build Status](https://travis-ci.org/jdesrosiers/sinatra-cors.svg?branch=master)](https://travis-ci.org/jdesrosiers/sinatra-cors)

Sinatra CORS
============
This Sinatra plugin supports the full CORS spec including automatic support for CORS preflight (OPTIONS) requests.  It uses CORS security best practices.  The plugin logs to the default logger to guide you in setting things up properly.  It will tell you why a CORS request failed and tell you how to fix it.

Get the Gem
-----------
https://rubygems.org/gems/sinatra-cors

Quick Start
-----------
The following is an example of how to create a CORS enabled route with some typical default configuration.

**IMPORTANT:** The plugin handles OPTIONS requests automatically, but if you have reason to add OPTIONS routes for some or all of your routes manually, you will need to put the `register Sinatra::Cors` line after the OPTIONS routes that you create.

**IMPORTANT:** The CORS settings must come after the `register Sinatra::Cors` line.

```ruby
require "sinatra"
require "sinatra/cors"

get "/foo" do
  "foo"
end

register Sinatra::Cors

set :allow_origin, "http://example.com http://foo.com"
set :allow_methods, "GET HEAD POST"
set :allow_headers, "content-type"
```

Settings
--------
* **allow_origin**: A space-separated list of allowed origins. (Example: "https://example.com")
* **allow_methods**: A space-separated list of allowed methods. (Example: "GET HEAD POST")
* **allow_headers**: A space-spearated list of allowed request headers. (Example: "content-type")
* **max_age**: The number of seconds you allow the client to cache a preflight response (Example: "500")
* **expose_headers**: A space-separated list of response headers the client will have access to. (Example: "location link")
* **allow_credentials**: If true, it will allow actual requests to send things like cookies, HTTP authentication, and client-side SSL certificates. (Example: true)

Comming Soon
------------
* Automatically determine `Allow` headers based on existing routes
* Route specific settings
