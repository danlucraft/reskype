class Reskype
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

        rows.map {|r| Chat.new(self, r)}
      end
    end

		def to_data
			data = {
				"chats" => {}
			}
			chats[0..5].each do |c|
				data["chats"][c.id] = c.to_data
			end
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

      def nice_name
        if !topic and participants.empty?
          return "adsf"
        end
        topic || participants.join(", ")
      end

      def name
        @h["name"]
      end

      def topic
        t = @h["topic"]
        t == "" ? nil : t
      end

      def details
        @h
      end

      def posters
        (@h["posters"] || "").split(" ")
      end

      def id
        @h["conv_dbid"]
      end

      def participants
        ((@h["participants"] || "").split(" ") + posters).uniq
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
				  "id" => id.to_s,
				  "chatname" => name.inspect,
				  "nice_name" => nice_name.inspect,
				  "posters" => posters,
				  "messages" => {}
				}
				messages.each do |m|
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
				@h["id"]
			end
			
			def convo_id
				@h["convo_id"]
			end

      def author
        @h["author"]
      end

      def body
        @h["body_xml"] || ""
      end

      def identities
        @h["identities"] || ""
      end

			def to_data
				{
					"id"         => id,
				  "author"     => author, 
				  "created_at" => created_at,
				  "body"       => body,
				  "identities" => identities
				}
			end
    end
  end
end
