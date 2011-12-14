
require 'reskype/skype5'
require 'reskype/skype3'

require 'strscan'

require 'rubygems'
require 'json'
require 'sqlite3'

class Reskype

  def self.chat_to_hash(chat)
    json = {
         "id" => chat.id.to_s,
         "chatname" => chat.name.inspect,
         "nice_name" => chat.nice_name.inspect,
         "posters" => chat.posters,
         "messages" => []
      }
    messages = []
    chat.messages.each do |message|
      json2 = {
       "author" => message.author, 
       "created_at" => message.created_at,
       "body" => message.body,
       "identities" => message.identities
      }
      json["messages"] << json2
    end
    json
  end
  
  def self.chat_basename(chat)
    chat.nice_name.gsub(",", "-").gsub(" ", "-").gsub(/[^A-Za-z\-_.0-9]/, "").gsub(/\.*$/, "")
  end

  def self.export(chats)
    chats.map do |chat|
      chat
    end
  end
end

user_dir = ARGV[0]
target_dir = ARGV[1]
main_db_paths = Dir[File.expand_path(user_dir) + "/*main.db"]

chats = []

main_db_paths.each do |main_db_path|
  reskype5 = Reskype::Skype5.new(main_db_path)
  chats += Reskype.export(reskype5.chats)
end

reskype3 = Reskype::Skype3.new(user_dir)
chats += Reskype.export(reskype3.chats)

unless File.exist?(target_dir)
  raise
end
  
chats.each do |chat|
  filename = "chat__" + Reskype.chat_basename(chat)
  path = target_dir + "/" + filename
  while File.exist?(path+".json")
    if path =~ /-(\d+)$/
      path = path[0..(-1*$1.length - 1)] + ($1.to_i + 1).to_s
    else
      path += "-1"
    end
  end
  File.open(path+".json", "w") do |f|
    chat_info = Reskype.chat_to_hash(chat)
    f.puts JSON.pretty_generate(chat_info)
  end
end



