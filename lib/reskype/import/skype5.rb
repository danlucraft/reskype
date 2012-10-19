module Reskype
	module Import
		class Skype5
			def initialize(filename)
				@filename = filename
			end

			def db
				@db ||= SQLite3::Database.new(@filename)
			end

			def num_messages
				db.execute("select count(*) from Messages").first.first
			end

			def num_chats
				db.execute("select count(*) from Chats").first.first
			end

			def chat_columns
				@chat_columns ||= columns("Chats")
			end

			def message_columns
				@message_columns ||= columns("Messages")
			end

			def columns(table)
				columns = db.execute2("PRAGMA table_info(#{table})")
				column_columns = columns[0]
				columns = columns[1..-1]
				name_ix = column_columns.index("name")
				columns.map {|r| r[name_ix]}
			end

			def chats
				@chats ||= begin
					columns, *rows = db.execute2("select * from Chats order by last_change desc")

					rows.map do |r| 
						Chat.new(self, r)
					end
				end
			end

			def user_id(skypename)
				@users ||= {}
				return @users[skypename]["id"] if @users[skypename]

				columns, *rows = db.execute2("select id,fullname from Contacts where skypename = \"#{skypename}\"")
				id, fullname = *rows.first
				@users[skypename] = {"id" => id, "skypename" => skypename, "fullname" => fullname}
				id
			end

			def users
				@users || {}
			end

			def to_data
				data = {
					"chats" => {}
				}
				cs = chats
				cs = cs[0..5] if ENV["RESKYPE_DEBUG"]
				cs.each do |c|
					data["chats"][c.id] = c.to_data
				end
				data["users"] = users.values
				data
			end
			
			class Chat
				attr_reader :skype5

				def initialize(skype5, row)
					@skype5 = skype5
					@row = row
					@h = {}
					skype5.chat_columns.each do |row_name|
						@h[row_name] = @row[skype5.chat_columns.index(row_name)]
					end
				end

				def id
					@h["conv_dbid"].to_i
				end

				def name
					@h["name"]
				end

				def topic
					@h["topic"]
				end

				def posters
					(@h["posters"] || "").split(" ")
				end

				def participants
				  (@h["participants"] || "").split(" ").uniq
				end

				def num_messages
					skype5.db.execute("select count(*) from Messages where chatname = '#{name}'").first.first
				end

				def messages
					@messages ||= begin
						columns, *rows = skype5.db.execute2("select * from Messages where convo_id = #{id} order by timestamp desc")
						rows.map {|r| Message.new(skype5, r)}
					end
				end

				def to_data
					data = {
						"id" => id,
						"name" => name,
						"topic" => topic,
						"posters" => posters,
						"participants" => participants,
						"messages" => {}
					}
					ms = messages
					ms = ms[0..10] if ENV["RESKYPE_DEBUG"]
					ms.each do |m|
						data["messages"][m.id] = m.to_data
					end
					data
				end
			end

			class Message
				attr_reader :skype5

				def initialize(skype5, row)
					@skype5 = skype5
					@row = row
					@h = {}
					skype5.message_columns.each do |row_name|
						@h[row_name] = @row[skype5.message_columns.index(row_name)]
					end
				end

				def created_at
					Time.at(@h["timestamp"])
				end

				def id
					@h["id"].to_i
				end
				
				def convo_id
					@h["convo_id"].to_i
				end

				def author
					@h["author"]
				end

				def body
					@h["body_xml"]
				end

				def identities
					@h["identities"]
				end

				def to_data
					{
						"id"         => id,
						"chat_id"    => convo_id,
						"user_id"    => skype5.user_id(author), 
						"created_at" => created_at,
						"body"       => body,
						"identities" => identities
					}
				end
			end
		end
	end
end
