
EXPLICIT_INCLUDES = <<TXT.split("\n")
chat__The-CalTraks.json
chat__Platform--API-Team.json
chat__Contact-Importer-QA-Chat.json
chat__Cocktail-Chat.json
chat__Spotify-Playlist---Songkick-HQ---httpshrt.st9ou.json
chat__Pontypandy-Fire-Station.json
chat__SKYRIM.json
chat__team-getting-the-iphone-app-done.json
chat__Cocktail-chat.json
chat__FBIP-Facebook-Intrusion-of-Privacy-1.json
chat__FBIP-Facebook-Intrusion-of-Privacy.json
chat__Spotify-Playlist---Songkick-HQ---httpshrt.st9ou.json
chat__Data-collection.json
chat__Bugs-and-Spam-egg-sausage-and-spam.json
chat__curl-httpscrapy-site.com--devnull.json
TXT

module Reskype
  class App < Sinatra::Base
    PER_PAGE = 500
    
    def initialize
      load_data
      super
    end
    
    get "/" do
      @sorted_people = @history.people.to_a.sort_by {|n, ms| ms.length}.reverse
      erb :index
    end
    
    get "/chat/:chat_id" do
      @chat_id = params[:chat_id]
      @chat = @chats.detect {|c| c["id"] == @chat_id}
      @total = @chat["messages"].length
      @pages = (@total / PER_PAGE) + 1
      messages = @chat["messages"].reverse
      if params[:message]
        if ix = messages.map {|m| m["unique_id"]}.index(params[:message].to_i)
          @page = ix/PER_PAGE
        end
      end
      @page ||= (params[:page] || (@pages - 1)).to_i
      @messages = messages[@page*PER_PAGE..(@page + 1)*PER_PAGE]
      @name = @chat["nice_name"][1..-2]

      @page_type = "chat"
      @page_id = @chat["id"]
      @show_chat_name = false
      erb :chat
    end
    
    get "/user/:user_id" do
      @user_id = params[:user_id]
      @total = @people[@user_id].length
      @pages = (@total / PER_PAGE) + 1
      @page = (params[:page] || (@pages - 1)).to_i
      messages = @people[@user_id]
      @messages = messages.reverse[@page*PER_PAGE..(@page + 1)*PER_PAGE]
      @name = @user_id
      @page_type = "user"
      @page_id = @user_id
      @show_chat_name = true
      erb :chat
    end
    
    def load_data
			base = Db::Base.new
			@history = base.history
    end
  end
end





