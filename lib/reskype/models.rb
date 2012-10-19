module Reskype
	class Chat < Sequel::Model
		def messages
			Message.where(:chat_id => id).to_a
		end

		def participants
			messages.map(&:user_id).uniq.map {|id| User[:id => id] }
		end

		def nice_name
			topic || participants[0..5].map(&:username).join(", ")
		end
	end

	class User < Sequel::Model
		def messages
			Message.where(:user_id => id).to_a
		end
	end

	class Message < Sequel::Model
		def chat
			Chat[:id => chat_id]
		end

		def user
			User[:id => user_id]
		end
	end
end
