
require 'reskype/skype5'
require 'reskype/skype3'

class Reskype

  def self.to_s(chats)
    str = ""
    str << "num chats: #{chats.length}\n"
    str << "\n"
    str << "Chats:\n"
    chats.each do |chat|
      str << "  #{chat.id.to_s.rjust(6)} #{chat.name.inspect.ljust(60)} #{chat.nice_name.ljust(50)} #{chat.messages.length}\n"
    end
    
    str << "\n"
    str << "Messages:\n"
    chats.each do |chat|
      str << "  #{chat.nice_name}:\n"
      chat.messages.each do |message|
        str << "    #{message.author.ljust(20)} #{message.created_at} #{message.body.split("\n").map {|l| " "*25 + l}.join("\n")}\n"
      end
    end
    str
  end
end

reskype = Reskype::Skype3.new(ARGV[0])
puts Reskype.to_s(reskype.chats)

# 
# reskype = Reskype::Skype5.new(ARGV[0])
# puts reskype.to_s