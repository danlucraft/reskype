module Reskype
	module Db
		class History

			def initialize(data)
				@data = data
			end

			def clear
				@chats = nil
				@people = nil
			end

			def chats
				@chats ||= begin
					cs = []
					@data["chats"].each {|c_id, h| cs << Chat.new(h) }
      		cs = cs.sort_by {|c| c.messages.last.created_at}.reverse
					cs
				end
			end

			def people
      	@people ||= begin
											s = Time.now
					ps = Hash.new { |hash, key| hash[key] = [] }

					chats.each do |chat|
						chat.messages.each do |message|
							ps[message.author] << message
						end
					end

					ps.each {|n, ms| ps[n] = ms.sort_by {|m| m.created_at}.reverse}
					puts "indexing people messages took #{Time.now - s}s"
					ps
				end
			end

			def add(new_data)
				new_data["chats"].each do |chat_id, chat_info|
					if old_chat = chats[chat_id]
						old_chat.merge(chat_info)
					else
						@data["chats"][chat_id] = chat_info
					end
				end
				clear
			end

			def inspect
				"#<Reskype::Db::History #{chats.length} chats #{chats.inject(0) {|m, c| m += c.messages.length}} messages>"
			end

			def to_data
				@data
			end
		end
	end
end
