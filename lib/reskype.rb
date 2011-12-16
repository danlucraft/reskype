
require 'strscan'

require 'rubygems'
require 'json'
require 'sqlite3'
require 'sinatra'

require 'reskype/skype5'
require 'reskype/skype3'
require 'reskype/app'

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
