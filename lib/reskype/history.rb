module Reskype
	class History
		def add(new_data)
			new_data["users"].each do |user_info|
				find_or_create_author(user_info["id"], user_info["skypename"], user_info["fullname"])
			end

			new_data["chats"].each do |chat_id, chat_info|
				unless Chat[:id => chat_id.to_i]
					Chat.create(:name => chat_info["name"], 
											:id => chat_id.to_i,
											:topic => chat_info["topic"])
				end
				chat_info["messages"].each do |_, message|
					unless Message[:id => message["id"].to_i]
						Message.create(:user_id => message["user_id"], 
													 :body => message["body"], 
													 :id => message["id"].to_i, 
													 :created_at => message["created_at"], 
													 :chat_id => message["chat_id"])
					end
				end
			end
		end

		def find_or_create_author(id, skypename, fullname)
			if a = User[:id => id]
			else
				User.create(:id => id, :username => skypename, :fullname => fullname)
			end
		end

		def inspect
			"#<Db::History #{Chat.count} chats #{Message.count} messages>"
		end

		def to_data
			@data
		end
	end
end
