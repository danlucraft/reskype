module Reskype
	module Db
		class Base
			DEFAULT_DB_PATH = File.expand_path("~/.reskype.sqlite")

			attr_reader :filename

			def initialize(filename=DEFAULT_DB_PATH)
				@filename = filename
			end

			def db
				@db ||= SQLite3::Database.new(filename)
			end

			def history
				@history ||= begin
					h = History.new(db)
				end
			end

			def add(new_data)
				history.add(new_data)
			end
		end
	end
end
