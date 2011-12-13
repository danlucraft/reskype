
class Reskype
  class Skype3
    def initialize(dir)
      @dir = dir
    end
    
    def chatmsg_files
      Dir[@dir + "/chatmsg*.dbb"]
    end

    def chat_files
      Dir[@dir + "/chat*.dbb"]
    end

    def messages
      chatmsg_files.map { |file|
        MsgParser.new(File.open(file, "rb") {|f| f.read }).messages
      }.flatten.map {|h| Message.new(h)}
    end
    
    def chats
      @chats ||= begin
        chats = {}
        messages.each do |message|
          chats[message.chatname] ||= Chat.new(message.chatname)
          chats[message.chatname].messages << message
        end
        chats.values.each {|c| c.messages.sort_by {|m| m.created_at}.reverse}
      end
    end
    
    class Chat
      attr_reader :messages
      
      def initialize(name)
        @name = name
        @messages = []
      end
      
      def id
        @name
      end
      
      def nice_name
        @name
      end
      
      def name
        @name
      end
    end
    
    class Message
      def initialize(hash)
        @hash = hash
      end
      
      def chatname
        @hash[:chatname]
      end
      
      def created_at
        @hash[:timestamp]
      end
      
      def author
        @hash[:sender]
      end
      
      def body
        @hash[:body]
      end
    end
    
    class MsgParser
      attr_reader :messages
      
      def initialize(content)
        @content = content
        @offset = 0
        @messages = []
        @scanner = StringScanner.new(content)
        begin
          i = 0
          loop do
            read_message
            i += 1
            puts i if i % 1000 == 0
          end
        rescue
        end
      end
      
      def read_message
        message = {}
        
        find_start_of_message
        message[:chatname] = "#" + @scanner.scan_until(Regexp.new("\x00"))[0..-2]
        
        find_timestamp
        message[:timestamp] = process_timestamp(@scanner.scan(/...../))
        
        find_sender
        message[:sender] = @scanner.scan_until(Regexp.new("\x00"))[0..-2]
        
        find_start_of_body
        message[:body] = @scanner.scan_until(Regexp.new("\x00"))[0..-2]

        find_sender_display_name
        message[:sender_display_name] = @scanner.scan_until(Regexp.new("\x00"))[0..-2]

        @messages << message
      end

      def find_start_of_message
        @scanner.skip_until(Regexp.new("\xE0\x03\x23"))
      end
      
      def find_timestamp
        @scanner.skip_until(Regexp.new("\xE5\x03"))
      end
      
      def find_sender
        @scanner.skip_until(Regexp.new("\xE8\x03"))
      end
      
      def find_start_of_body
        @scanner.skip_until(Regexp.new("\xFC\x03"))
      end
      
      def find_sender_display_name
        @scanner.skip_until(Regexp.new("\xEC\x03"))
      end
      
      def process_timestamp(string)
        bytes = string.reverse.unpack("C*").map{|b|b.to_s(2).rjust(8, "0")}
        new_value = [bytes[0][4..-1], bytes[1..-1].map {|b| b[1..-1]}].join.to_i(2)
        Time.at(new_value)
      end
    end
  end
end