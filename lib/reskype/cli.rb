module Reskype
	class CLI
		def usage
			puts "USAGE: ruby bin/parse import SKYPE_DB"
			puts "       ruby bin/parse import5 SKYPE_DB"
			puts "       ruby bin/parse import3 SKYPE_DB"
			puts "       ruby bin/parse debug5 SKYPE_DB"
			puts
			puts "On OSX the db file is likely to be /Users/dan/Library/Application\ Support/Skype/USERNAME/main.db"
			puts "The chat db is stored as ~/reskype.json"
			exit
		end

		def database_filepath
			File.expand_path("~/reskype.json")
		end

		def run
			if ARGV.include?("-h") or ARGV.include?("--help")
				usage
			end
			case ARGV[0]
			when "process"
				process
			when "debug5"
				debug5
			when "import5"
				import5
			else
				usage
			end
		end

		def import5
			file = ARGV[1]
			unless file and File.exist?(file)
				puts "SKYPE_DB not found\n"
				usage
			end

			base = Db::Base.new
			Reskype::Import::Skype5.new(file).import(base)
		end

		def debug5
			file = ARGV[1]
			unless file and File.exist?(file)
				puts "SKYPE_DB not found\n"
				usage
			end
		  puts "Skype5 #{file}"
			reskype5 = Reskype::Import::Skype5.new(file)
			puts "  Chats: #{reskype5.chats.length}"
			puts JSON.pretty_generate(reskype5.to_data)
		end

		def process
			user_dir = ARGV[1]
			unless user_dir and File.exist?(user_dir)
				puts "SKYPE_DIR not found"
				usage
			end

			target_dir = ARGV[2]
			unless target_dir and File.exist?(target_dir) and File.directory?(target_dir)
				puts "TARGET_DIR not found"
				usage
			end

			main_db_paths = Dir[File.expand_path(user_dir) + "/*main.db"]

			chats = []

			main_db_paths.each do |main_db_path|
				puts main_db_path
				reskype5 = Reskype::Import::Skype5.new(main_db_path)
				chats += export(reskype5.chats)
			end

			reskype3 = Reskype::Import::Skype3.new(user_dir)
			chats += export(reskype3.chats)

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
					begin
						f.puts JSON.pretty_generate(chat_info)
					rescue Encoding::UndefinedConversionError
						puts "undefined encoding error in #{chat.name}"
					end
				end
			end
		end	

		def export(chats)
			chats.map do |chat|
				chat
			end
		end

	end
end
