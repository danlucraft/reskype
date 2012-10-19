module Reskype
	class Chat < Sequel::Model
		def num_messages
			@num_messages ||= Message.where(:chat_id => id).count
		end

		def messages
			Message.where(:chat_id => id).order(:created_at).to_a
		end

		def first_message
			Message.where(:chat_id => id).order(:created_at).last
		end

		def last_message
			Message.where(:chat_id => id).order(:created_at).first
		end

		def participants
			messages.map(&:user_id).uniq.map {|id| User[:id => id] }
		end
	end

	class User < Sequel::Model
		def num_messages
			@num_messages ||= Message.where(:user_id => id).count
		end

		def messages
			Message.where(:user_id => id).order(:created_at).to_a
		end

		def first_message
			Message.where(:user_id => id).order(:created_at).last
		end

		def last_message
			Message.where(:user_id => id).order(:created_at).first
		end

		def name
			fullname || username
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
