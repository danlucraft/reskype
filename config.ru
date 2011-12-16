USE_REDIS = false

$:.push(File.expand_path("../lib", __FILE__))
require 'reskype'

run Reskype::App
