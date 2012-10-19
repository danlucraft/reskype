module Reskype
	module Db
		class Base
			DEFAULT_DB_PATH = File.expand_path("~/.reskype.sqlite")

			attr_reader :filename

			def initialize(filename=DEFAULT_DB_PATH)
				@filename = filename
				Sequel::Model.db = Sequel.sqlite(DEFAULT_DB_PATH)
				require 'reskype/models'
			end

			def schema_path
				File.expand_path("../schema.sql", __FILE__)
			end

			def migrate
				system("cat #{schema_path} | sqlite3 #{DEFAULT_DB_PATH}")
			end

			def add_user(u)
				unless User[:id => u["id"].to_i]
					User.create(:id => u["id"].to_i, :username => u["username"], :fullname => u["fullname"])
				end
			end

			def add_chat(chat_info)
				unless Chat[:id => chat_info["id"].to_i]
					Chat.create(:name => chat_info["name"], 
											:id => chat_info["id"].to_i,
											:topic => chat_info["topic"])
				end
			end

			def add_message(message)
				unless Message[:id => message["id"].to_i]
					Message.create(:user_id => message["user_id"], 
												 :body => message["body"], 
												 :id => message["id"].to_i, 
												 :created_at => message["created_at"], 
												 :chat_id => message["chat_id"])
				end
			end

			def inspect
				"#<Db::Base #{Chat.count} chats #{Message.count} messages>"
			end
		end
	end
end
