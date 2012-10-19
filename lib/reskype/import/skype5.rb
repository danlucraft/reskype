module Reskype
	module Import
		class Skype5
			def initialize(filename)
				@filename = filename
			end

			def db
				@db ||= SQLite3::Database.new(@filename)
			end

			def hashify(columns, row)
				h = {}
				columns.zip(row) do |column_name, value|
					h[column_name] = value
				end
				h
			end

			def import2(history)
				system("sqlite3 -csv \"#{@filename}\" \"select id,name,topic from Chats\" > Chats.csv")
				system("sqlite3 -csv \"#{@filename}\" \"select id,convo_id,author,timestamp,body_xml,identities from Messages\" > Messages.csv")
				system("sqlite3 -csv \"#{@filename}\" \"select id,skypename,fullname from Contacts\" > Contacts.csv")

				#jFile.open("new_chats.sql", "w") do |f|
					#jCSV.foreach("Chats.csv") do |row|


				
				users = {}
				CSV.foreach("Contacts.csv") do |row|
					id, skypename, fullname = *row
					users[skypename] = {:id => id, :skypename => skypename, :fullname => fullname }
				end

			end

      def import(history)
				import_chats(history)
				users = import_users(history)
				import_messages(history, users)
			end

			def import_chats(history)
				_, *rows = db.execute2("select id,name,topic from Chats")

				File.open("chats.sql", "w") do |f|
					rows.map do |id, name, topic|
						f.puts "insert into chats (id, name, topic) values (#{id}, #{name.inspect}, #{topic ? topic.inspect : "NULL"});"
					end
				end
			end

			def import_messages(history, users)
				columns, *rows = db.execute2("select id,convo_id,author,timestamp,body_xml,identities from Messages")
				File.open("messages.sql", "w") do |f|
					rows.map do |id, chat_id, skypename, timestamp, body, identities|
						user_id = users[skypename]
						created_at = Time.at(timestamp.to_i)
						f.puts "insert into messages (id, chat_id, user_id, created_at, body, identities) values (#{id}, #{chat_id}, #{user_id}, #{created_at}, #{body ? body.inspect : "NULL"}, #{identities ? identities.inspect : "NULL"});"
					end
				end
			end

			def import_users(history)
				_, *rows = db.execute2("select id,skypename,fullname from Contacts")
				u = {}
				File.open("users.sql", "w") do |f|
					rows.map do |id, username, fullname|
						u[username] = id
						f.puts "insert into users (id, username, fullname) values (#{id}, #{username ? username.inspect : "NULL"}, #{fullname ? fullname.inspect : "NULL"});"
					end
				end
				u
			end

		end
	end
end
