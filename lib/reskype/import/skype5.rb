module Reskype
	module Import
		class Skype5
			def initialize(filename)
				@filename = filename
			end

			def db
				@db ||= SQLite3::Database.new(@filename)
			end

			def id_namespace
				@space ||= begin
				if space = ENV["RESKYPE_ID_SPACE"]
					space.to_i
				else
					raise "missing RESKYPE_ID_SPACE"
				end
									 end
			end

			def idify(id)
				id.to_i*10 + id_namespace
			end

			def hashify(columns, row)
				h = {}
				columns.zip(row) do |column_name, value|
					h[column_name] = value
				end
				h
			end

      def import(history)
				chats = import_chats(history)
				users = import_users(history)
				import_messages(history, users, chats)
			end

			def import_chats(history)
				c = {}
				_, *rows = db.execute2("select conv_dbid,name,topic from Chats")

				File.open("chats.sql", "w") do |f|
					rows.map do |id, name, topic|
						if ENV["RESKYPE_PRIVATE"] or (topic and topic != "")
							c[id] = topic
							f.puts "insert into chats (id, name, topic) values (#{idify(id)}, #{name.inspect}, #{topic ? topic.inspect : "NULL"});"
						end
					end
				end

				history.import_sql("chats.sql")
				c
			end

			def escape(string)
				string.gsub("\"", "\"\"")
			end

			def import_messages(history, users, chats)
				columns, *rows = db.execute2("select id,convo_id,author,timestamp,body_xml,identities from Messages")
				File.open("messages.sql", "w") do |f|
					rows.map do |id, chat_id, skypename, timestamp, body, identities|
						if chats[chat_id.to_i]
							if user_id = users[skypename]
							else
								user_id = 1000000 + rand(1000000)
								f.puts "insert into users (id, username, fullname) values (#{idify(user_id)}, #{skypename.inspect}, NULL);"
							end
							created_at = Time.at(timestamp.to_i)
							f.puts "insert into messages (id, chat_id, user_id, created_at, body, identities) values (#{idify(id)}, #{idify(chat_id)}, #{idify(user_id)}, #{created_at.to_s.inspect}, #{body ? "\"" + escape(body) + "\"": "NULL"}, #{identities ? identities.inspect : "NULL"});"
						end
					end
				end

				history.import_sql("messages.sql")
			end

			def import_users(history)
				_, *rows = db.execute2("select id,skypename,fullname from Contacts")
				u = {}
				File.open("users.sql", "w") do |f|
					rows.map do |id, username, fullname|
						u[username] = id
						f.puts "insert into users (id, username, fullname) values (#{idify(id)}, #{username ? username.inspect : "NULL"}, #{fullname ? fullname.inspect : "NULL"});"
					end
				end
				history.import_sql("users.sql")
				u
			end

		end
	end
end
