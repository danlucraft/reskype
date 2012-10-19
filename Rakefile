$:.push(File.expand_path("../lib", __FILE__))
require 'reskype'

namespace :db do
	task :migrate do
    Reskype::Db::Base.new.migrate
	end
end

