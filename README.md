[![Build Status](https://travis-ci.org/jdesrosiers/sinatra-cors.svg?branch=master)](https://travis-ci.org/jdesrosiers/sinatra-cors)

Sinatra CORS
============
I was shocked to find that Sinatra didn't already have good plugin for CORS support, so I decided to make one.  This plugin supports the full CORS spec including automatic support for CORS preflight (OPTIONS) requests.  It also bakes in CORS security best practices.  In some cases this makes it a little harder to get up and running, but the plugin will log information to guide you in setting things up properly.

Quick Start
-----------
The following is an example of how to create a route and setup some minimal configuration.

**IMPORTANT:** If you want to add your own OPTIONS routes for some or all of your routes manually, you will need to put the `register Sinatra::Cors` line after the OPTIONS routes that you create.

**IMPORTANT:** The CORS settings must come after the `register Sinatra::Cors` line.

```ruby
require "sinatra"
require "./lib/sinatra/cors"

get "/foo" do
  "foo"
end

register Sinatra::Cors

set :allow_origin, "http://example.com http://foo.com"
set :allow_methods, "GET HEAD POST"
set :allow_headers, "content-type if-modified-since"
```

Settings
--------
* **allow_origin**: A space separated list of allowed origins. (Example: "https://example.com")
* **allow_methods**: A space separated list of allowed methods. (Example: "GET HEAD POST")
* **allow_headers**: A space spearated list of allowed request headers. (Example: "content-type")
* **max_age**: The number of seconds you allow the client to cache a preflight response (Example: "500")
* **expose_headers**: A space separated list of response headers the client will have access to. (Example: "location link")
* **allow_credentials**: If true, it will allow actual requests to send things like cookies, HTTP authentication, and client-side SSL certificates. (Example: true)

Comming Soon
------------
* Logging to guide users through CORS errors
* Automatically determine `Allow` headers based on existing routes
* Route specific settings
