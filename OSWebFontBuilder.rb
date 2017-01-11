require "json"
require 'text2svg'
require 'SecureRandom'

config = JSON.parse(File.read("#{Dir.pwd}/config/config.json"))

if config["analyse"][0][0] == true
	require 'chunky_png'
end

fonts = Dir.entries("#{Dir.pwd}/fonts")

if File.exists?("#{config["build_path"]}/builds/") == false
	`mkdir #{config["build_path"]}/builds/`
end

##Delete Both Relative Paths ./ ../
fonts.delete_at(0)
fonts.delete_at(0)

fonts.each do |font|
	font_exists = false
	font_info = JSON.parse(File.read("#{Dir.pwd}/fonts/#{font}/info.json"))
	
	if File.exists?("#{config["build_path"]}/builds/#{font}_version.txt") == true
		if not font_info["repo_version"] == File.read("#{config["build_path"]}/builds/#{font}_version.txt")
			font_exists = true
		end
	end
	if font_exists == false
		
		if config["gen_preview"] == true
			svg_text_normal = Text2svg(config["gen_preview_string"], font: "#{Dir.pwd}/fonts/#{font}/#{font_info["font_file"]}", text_align: :left, bold: false, italic: false)
			svg_text_bold = Text2svg(config["gen_preview_string"], font: "#{Dir.pwd}/fonts/#{font}/#{font_info["font_file"]}", text_align: :left, bold: true, italic: false)
			svg_text_italic = Text2svg(config["gen_preview_string"], font: "#{Dir.pwd}/fonts/#{font}/#{font_info["font_file"]}", text_align: :left, bold: false, italic: true)
			
			File.open("#{config["build_path"]}/builds/#{font}_normal.svg", 'w') { |file| file.write("#{svg_text_normal}")}
			File.open("#{config["build_path"]}/builds/#{font}_bold.svg", 'w') { |file| file.write("#{svg_text_bold}")}
			File.open("#{config["build_path"]}/builds/#{font}_italic.svg", 'w') { |file| file.write("#{svg_text_italic}")}
		end
		
		
		
		if config["analyse"][0][0] == true
			##Volume Analysis
			black_pixels = 0
			white_pixels = 0
			
			totals = []
			config["gen_preview_string"].dup.gsub(" ", "").gsub("\n", "").split("").each do |letter|
				letter_filename = SecureRandom.hex(3)
				`convert -background "#FFFFFF" -fill black -font #{Dir.pwd}/fonts/#{font}/#{font_info["font_file"]} -pointsize 300 label:"\\#{letter}" #{config["build_path"]}/builds/#{font}_#{letter_filename}.png`
				totals << [letter, "#{config["build_path"]}/builds/#{font}_#{letter_filename}.png", "B0", "W0", "%"]
			
				if File.exists?("#{config["build_path"]}/builds/#{font}_#{letter_filename}.png") == false
					totals.last[2] = "ERROR"
					totals.last[3] = "ERROR"
					totals.last[4] = "ERROR"
				else
					image = ChunkyPNG::Image.from_file("#{config["build_path"]}/builds/#{font}_#{letter_filename}.png")
					
					width = image.dimension.width
					height = image.dimension.height
					(0..width - 1).each do |x|
					  (0..height- 1).each do |y|
					    if ChunkyPNG::Color.r(image[x,y]) == 0 && ChunkyPNG::Color.g(image[x,y]) == 0 && ChunkyPNG::Color.b(image[x,y]) == 0
					    	black_pixels = black_pixels + 1
					    else
					    	white_pixels = white_pixels + 1
					    end
					  end
					end
					totals.last[2] = black_pixels
					totals.last[3] = white_pixels
					totals.last[4] = ((black_pixels.to_f/(black_pixels.to_f + white_pixels.to_f)) * 100)
				end
			end
			puts totals
		end
	end
end