Gem::Specification.new do |s|
  s.name = "sinatra-cors"
  s.version = "0.1.1"
  s.date = "2017-06-28"
  s.summary = "CORS support for Sinatra applications"
  s.description = <<-EOT
This Sinatra plugin supports the full CORS spec including automatic support for CORS preflight (OPTIONS) requests.  It uses CORS security best practices.  The plugin logs to the default logger to guide you in setting things up properly.  It will tell you why a CORS request failed and tell you how to fix it.
  EOT
  s.authors = ["Jason Desrosiers"]
  s.email = "jdesrosi@gmail.com"
  s.files = ["lib/sinatra/cors.rb"]
  s.homepage = "https://github.com/jdesrosiers/sinatra-cors"
  s.license = "MIT"
end
