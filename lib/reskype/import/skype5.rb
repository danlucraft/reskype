module Reskype
	module Import
		class Skype5
			def initialize(filename)
				@filename = filename
			end

			def db
				@db ||= SQLite3::Database.new(@filename)
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

			def hashify(columns, row)
				h = {}
				columns.zip(row) do |column_name, value|
					h[column_name] = value
				end
				h
			end

      def import(history)
				import_chats(history)
				import_messages(history)
				import_users(history)
			end

			def import_chats(history)
				columns, *rows = db.execute2("select * from Chats")

				rows.map do |r| 
					row = hashify(columns, r)
					history.add_chat(
						"id" => row["conv_dbid"],
						"name" => row["name"],
						"topic" => row["topic"]
					)
				end
			end

			def import_messages(history)
				columns, *rows = db.execute2("select * from Messages")
				rows.map do |r| 
					row = hashify(columns, r)
					history.add_message(
						"id" => row["id"],
						"chat_id" => row["convo_id"],
						"user_id" => user_id(row["author"]),
						"body" => row["body_xml"],
						"identities" => row["identities"],
						"created_at" => Time.at(row["timestamp"])
					)
				end
			end

			def import_users(history)
				@users.each do |user|
					history.add_user(
						"id" => user["id"],
						"username" => user["skypename"],
						"fullname" => user["fullname"]
					)
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

		end
	end
end
