
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
    
    get "/" do
			@sorted_people = User.all
      erb :index
    end
    
    get "/chat/:chat_id" do
      @chat_id = params[:chat_id]
			@chat = Chat[:id => @chat_id]
      @total = @chat.messages.length
      @pages = (@total / PER_PAGE) + 1
      messages = @chat.messages.reverse
      if params[:message]
        if ix = messages.map {|m| m["unique_id"]}.index(params[:message].to_i)
          @page = ix/PER_PAGE
        end
      end
      @page ||= (params[:page] || (@pages - 1)).to_i
      @messages = messages[@page*PER_PAGE..(@page + 1)*PER_PAGE]
      @name = @chat.nice_name

      @page_type = "chat"
      @page_id = @chat.id
      @show_chat_name = false
      erb :chat
    end
    
    get "/user/:user_id" do
      @user_id = params[:user_id]
      @user = User[:id => @user_id]
			@total = @user.messages.length
			@messages = @user.messages
      @pages = (@total / PER_PAGE) + 1
      @page = (params[:page] || (@pages - 1)).to_i
      @messages = @messages.reverse[@page*PER_PAGE..(@page + 1)*PER_PAGE]
      @name = @user.username
      @page_type = "user"
      @page_id = @user_id
      @show_chat_name = true
      erb :chat
    end
    
    def initialize
			base = Db::Base.new
			@history = base.history
			super
    end
  end
end





