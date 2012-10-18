
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

		def chats_columns
			@chats_columns ||= columns("Chats")
		end

		def messages_columns
			@messages_columns ||= columns("Messages")
		end

		def columns(table)
			columns = db.execute2("PRAGMA table_info(Messages)")
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

    class Chat
			attr_reader :skype5

      def initialize(skype5, row)
        skype5 = skype5
        @row = row
        @h = {}
        skype5.chats_columns.each do |row_name|
          @h[row_name] = @row[skype5.chats_columns.index(row_name)]
        end
      end

      def nice_name
        if !topic and participants.empty?
          return "adsf"
        end
        topic || participants.join(", ")
      end

      def name
        @row[skype5.chats_columns.index("name")]
      end

      def topic
        t = @row[skype5.chats_columns.index("topic")]
        t == "" ? nil : t
      end

      def details
        @h
      end

      def posters
        (@row[skype5.chats_columns.index("posters")] || "").split(" ")
      end

      def id
        @row[skype5.chats_columns.index("id")]
      end

      def participants
        ((@row[skype5.chats_columns.index("participants")] || "").split(" ") + posters).uniq
      end

      def num_messages
        skype5.db.execute("select count(*) from Messages where chatname = '#{name}'").first.first
      end

      def messages
        @messages ||= begin
          columns, *rows = skype5.db.execute2("select * from Messages where chatname = '#{name}' order by timestamp desc")
          rows.map {|r| Message.new(skype5, r)}
        end
      end
    end

    class Message
			attr_reader :skype5

      def initialize(skype5, row)
				skype5 = skype5
        @row = row
      end

      def created_at
        Time.at(@row[skype5.messages_columns.index("timestamp")])
      end

      def author
        @row[skype5.messages_columns.index("author")]
      end

      def body
        @row[skype5.messages_columns.index("body_xml")] || ""
      end

      def identities
        @row[skype5.messages_columns.index("identities")] || ""
      end
    end

  end
end
