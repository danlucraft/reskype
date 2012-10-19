module Reskype
	module Db
		class History
			attr_reader :db

			def initialize(db)
				@db = db
			end

			def num_messages
				db.execute("select count(*) from messages").first.first
			end

			def num_chats
				db.execute("select count(*) from chats").first.first
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
					db[:chats].insert(:name => chat_info["name"], :id => chat_id.to_i)
					chat_info["messages"].each do |_, message|
					  author_id = find_or_create_author(message["author"])
						p [message["author"], author_id]
						db[:messages].insert(:user_id => author_id, :body => message["body"])
					end
				end
				clear
			end

			def find_or_create_author(author_name)
				authors ||= {}
				if id = authors[author_name]
					return id
				end
				if a = db[:users].filter(:username => author_name).first
					id = a["id"]
				else
					id = db[:users].insert(:username => author_name)
				end
				authors[author_name] = id
				id
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
