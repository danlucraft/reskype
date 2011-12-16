USE_REDIS = false

$:.push(File.expand_path("../lib", __FILE__))
require 'reskype'

use Rack::Static, :urls => ["/css", "/images"], :root => "public"
run Reskype::App
