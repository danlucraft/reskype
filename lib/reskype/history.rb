module Reskype
	class History
		def add(new_data)
			new_data["chats"].each do |chat_id, chat_info|
				unless Chat[:id => chat_id.to_i]
					Chat.create(:name => chat_info["name"], 
											:id => chat_id.to_i,
											:topic => chat_info["topic"])
				end
				chat_info["messages"].each do |_, message|
					author_id = find_or_create_author(message["author"])
					unless Message[:id => message["id"].to_i]
						Message.create(:user_id => author_id, 
													 :body => message["body"], 
													 :id => message["id"].to_i, 
													 :created_at => message["created_at"], 
													 :chat_id => message["chat_id"])
					end
				end
			end
		end

		def find_or_create_author(author_name)
			@authors ||= {}
			if id = @authors[author_name]
				return id
			end
			if a = User[:username => author_name]
				id = a.id
			else
				id = User.create(:username => author_name).id
			end
			@authors[author_name] = id
			id
		end

		def inspect
			"#<Db::History #{Chat.count} chats #{Message.count} messages>"
		end

		def to_data
			@data
		end
	end
end
