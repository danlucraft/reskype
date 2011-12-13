
require 'sqlite3'

class Reskype
  def self.db
    @db ||= SQLite3::Database.new(ARGV[0])
  end
  
  def self.num_messages
    db.execute("select count(*) from Messages").first.first
  end
  
  def self.num_chats
    db.execute("select count(*) from Chats").first.first
  end
  
  def self.chats
    @chats ||= begin
      columns, *rows = db.execute2("select * from Chats order by last_change desc")
      rows.map {|r| Chat.new(r)}
    end
  end
  
  class Chat
    def initialize(row)
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
        p details
        return "adsf"
      end
      topic || participants.join(", ")
    end
    
    def name
      @row[ROWS.index("name")]
    end
    
    def topic
      @row[ROWS.index("topic")]
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
      (@row[ROWS.index("participants")] || "").split(" ")
    end
    
    def num_messages
      Reskype.db.execute("select count(*) from Messages where chatname = '#{name}'").first.first
    end
    
    def messages
      @messages ||= begin
        columns, *rows = Reskype.db.execute2("select * from Messages where chatname = '#{name}' order by timestamp desc")
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
    
    def author
      @row[ROWS.index("author")]
    end
    
    def body
      @row[ROWS.index("body_xml")] || ""
    end
  end
  
  def self.to_s
    str = ""
    str << "num chats: #{num_chats}\n"
    str << "num messages: #{num_messages}\n"
    str << "\n"
    str << "Chats:\n"
    chats.each do |chat|
      str << "  #{chat.id.to_s.rjust(6)} #{chat.name.inspect.ljust(60)} #{chat.nice_name.ljust(50)} #{chat.num_messages}\n"
    end
    
    str << "\n"
    str << "Messages:\n"
    chats.each do |chat|
      str << "  #{chat.nice_name}:\n"
      chat.messages.each do |message|
        str << "    #{message.author.ljust(20)} #{message.body.split("\n").map {|l| " "*25 + l}.join("\n")}\n"
      end
    end
    str
  end
end

puts Reskype.to_s

