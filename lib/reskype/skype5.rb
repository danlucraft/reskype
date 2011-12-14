
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
    
    def chats
      @chats ||= begin
        columns, *rows = db.execute2("select * from Chats order by last_change desc")
        rows.map {|r| Chat.new(self, r)}
      end
    end
    
    class Chat
      def initialize(skype5, row)
        @skype5 = skype5
        @row = row
        @row[ROWS.index("picture")] = nil
        @h = {}
        ROWS.each do |row_name|
          @h[row_name] = @row[ROWS.index(row_name)]
        end
      end
      
      ROWS = ["id", "is_permanent", "name", "options", "friendlyname", "description", "timestamp", 
        "activity_timestamp", "dialog_partner", "adder", "type", "mystatus", "myrole", "posters", 
        "participants", "applicants", "banned_users", "name_text", "topic", "topic_xml", "guidelines", 
        "picture", "alertstring", "is_bookmarked", "passwordhint", "unconsumed_suppressed_msg", 
        "unconsumed_normal_msg", "unconsumed_elevated_msg", "unconsumed_msg_voice", "activemembers", 
        "state_data", "lifesigns", "last_change", "first_unread_message", "pk_type", "dbpath", 
        "split_friendlyname", "conv_dbid", "extprop_hide_from_history", "extprop_chat_aux_type", 
        "extprop_chat_sort_order", "extprop_mark_read_immediately"]
      
      def nice_name
        if !topic and participants.empty?
          return "adsf"
        end
        topic || participants.join(", ")
      end
      
      def name
        @row[ROWS.index("name")]
      end
      
      def topic
        t = @row[ROWS.index("topic")]
        t == "" ? nil : t
      end
      
      def details
        @h
      end
      
      def posters
        (@row[ROWS.index("posters")] || "").split(" ")
      end
      
      def id
        @row[ROWS.index("id")]
      end
      
      def participants
        ((@row[ROWS.index("participants")] || "").split(" ") + posters).uniq
      end
      
      def num_messages
        @skype5.db.execute("select count(*) from Messages where chatname = '#{name}'").first.first
      end
      
      def messages
        @messages ||= begin
          columns, *rows = @skype5.db.execute2("select * from Messages where chatname = '#{name}' order by timestamp desc")
          rows.map {|r| Message.new(r)}
        end
      end
    end
    
    class Message
      ROWS = ["id", "is_permanent", "convo_id", "chatname", "author", "from_dispname", "author_was_live", 
        "guid", "dialog_partner", "timestamp", "type", "sending_status", "consumption_status", "edited_by", 
        "edited_timestamp", "param_key", "param_value", "body_xml", "identities", "reason", "leavereason", 
        "participant_count", "error_code", "chatmsg_type", "chatmsg_status", "body_is_rawxml", "oldoptions", 
        "newoptions", "newrole", "pk_id", "crc", "remote_id", "call_guid", "extprop_chatmsg_ft_index_timestamp", 
        "extprop_chatmsg_is_pending", "extprop_chatmsg_rendered_body", "extprop_chatmsg_render_version", 
        "extprop_chatmsg_aux_type", "extprop_chatmsg_aux_from_handle"]
        
      def initialize(row)
        @row = row
      end
      
      def created_at
        Time.at(@row[ROWS.index("timestamp")])
      end
      
      def author
        @row[ROWS.index("author")]
      end
      
      def body
        @row[ROWS.index("body_xml")] || ""
      end
      
      def identities
        @row[ROWS.index("identities")] || ""
      end
    end
    
  end
end  
