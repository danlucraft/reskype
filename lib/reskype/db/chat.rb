module Reskype
	module Db
		class Chat
			def initialize(data)
				@data = data
			end

			def clear
				@messages = nil
			end

			def id
				@data["id"]
			end

			def merge(other_data)
				@data["posters"] += other_data["posters"]
				@data["participants"] += other_data["participants"]
				other_data["messages"].each do |id, h|
					@data["messages"][id] = h
				end
				clear
			end

			def nice_name
				if !topic and participants.empty?
					return "adsf"
				end
				topic || participants.join(", ")
			end
				
			def name
				@data["name"]
			end

			def posters
				@data["posters"]
			end

			def participants
				@data["participants"]
			end

			def topic
				@data["topic"]
			end

			def messages
				@messages ||= begin
					ms = []
					@data["messages"].each {|id, h| ms << Message.new(h) }
					ms = ms.sort_by {|m| m.created_at }
					ms
				end
			end

			def to_data
				@data
			end
		end
	end
end

