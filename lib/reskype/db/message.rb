module Reskype
	module Db
		class Message
			def initialize(data)
				@data = data
			end

			def id
				@data["id"]
			end

			def author
				@data["author"]
			end

			def created_at
				Time.parse(@data["created_at"])
			end

			def body
				@data["body"]
			end

			def identities
				@data["identities"]
			end

			def to_data
				@data
			end
		end
	end
end
