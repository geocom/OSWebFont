require "json"
require 'text2svg'
require 'securerandom'
require 'kramdown'
config = JSON.parse(File.read("#{Dir.pwd}/config/config.json"))
index_page = ["<!DOCTYPE html><html><head><title>#{config["html_title"]}</title></head><body><div><h1>#{config["gen_domain"]} Font Repo</h1><p>This font repo has been built by the <a href=\"https://github.com/geocom/OSWebFont\">OSWebFont Script</a>. <h3>OSWebFont Disclamer</h3><p>The fonts included in this libary unless noted to our best knowlage are provided under the correct licenceing and opensource critera to be included. If you feel this is not the case open an issue at our GitHub page and we will take all concerns seriously however if your concern is related to a non-commercial requirement of your licence being broken please contact the owner of this site.</p><h3>#{config["gen_domain"]} Disclamer</h3><p>#{config["gen_disclamer"]}</p></div><div>"]
json_index_page = ["{"]
if config["analyse"][0] == true
	require 'chunky_png'
end

#Get Git Version
downloaded_version = `cd #{Dir.pwd}; git log --pretty=format:'%h' -n 1`

puts "Git Version: #{downloaded_version}"

fonts = Dir.entries("#{Dir.pwd}/fonts")
##Delete Both Relative Paths ./ ../
fonts.delete(".")
fonts.delete("..")

if not config["other_font_location"] == ""
	extra_fonts = Dir.entries(config["other_font_location"])
	extra_fonts.delete(".")
	extra_fonts.delete("..")
	fonts.push(*extra_fonts)
end

if File.exists?("#{config["build_path"]}/builds/") == false
	`mkdir #{config["build_path"]}/builds`
end
if File.exists?("#{config["build_path"]}/builds/assets") == false
	`mkdir #{config["build_path"]}/builds/assets`
end
if File.exists?("#{config["build_path"]}/builds/tmp") == true
	`rm -rf #{config["build_path"]}/builds/tmp`
	`mkdir #{config["build_path"]}/builds/tmp`
else
	`mkdir #{config["build_path"]}/builds/tmp`
end

fonts.each do |font|
	font_exists = false
	font_pass_test = true
	font_info = JSON.parse(File.read("#{Dir.pwd}/fonts/#{font}/info.json"))
	puts font
	if not config["blacklist"].include?("#{font}")
		if config["build_content_rating"].include?(font_info["content_rating"]) && config["build_content_type"].include?(font_info["build_content_type"])
			if not config["exclude_licence_containing"].include?(font_info["programmer_licence"])
				if config["skip_version_check"] == false
					if File.exists?("#{config["build_path"]}/assets/#{font}/version.txt") == true
						if not font_info["repo_version"] == File.read("#{config["build_path"]}/assets/#{font}/version.txt")
							puts "Font Has Already Processed"
							font_exists = true
						end
					end
				end
				if font_exists == false
					if File.exists?("#{config["build_path"]}/builds/assets/#{font}") == false
						`mkdir #{config["build_path"]}/builds/assets/#{font}`
					end
					svg_text_normal = Text2svg(config["gen_preview_string"], font: "#{Dir.pwd}/fonts/#{font}/#{font_info["font_file"]}", text_align: :left, bold: false, italic: false)
					svg_text_bold = Text2svg(config["gen_preview_string"], font: "#{Dir.pwd}/fonts/#{font}/#{font_info["font_file"]}", text_align: :left, bold: true, italic: false)
					svg_text_italic = Text2svg(config["gen_preview_string"], font: "#{Dir.pwd}/fonts/#{font}/#{font_info["font_file"]}", text_align: :left, bold: false, italic: true)

					File.open("#{config["build_path"]}/builds/assets/#{font}/normal.svg", 'w') { |file| file.write("#{svg_text_normal}")}
					File.open("#{config["build_path"]}/builds/assets/#{font}/bold.svg", 'w') { |file| file.write("#{svg_text_bold}")}
					File.open("#{config["build_path"]}/builds/assets/#{font}/italic.svg", 'w') { |file| file.write("#{svg_text_italic}")}
					if config["analyse"][0] == true
						##Volume Analysis
						totals = []
						quick_totals = []
						config["gen_preview_string"].dup.gsub(" ", "").gsub("\n", "").split("").each do |letter|
							black_pixels = 0
							white_pixels = 0
							letter_filename = SecureRandom.hex(3)
							if not config["no_antialias_on_analyse"] == true
								`convert -background "#FFFFFF" -fill black -font #{Dir.pwd}/fonts/#{font}/#{font_info["font_file"]} -trim -pointsize 300 label:"\\#{letter}" #{config["build_path"]}/builds/tmp/#{font}_#{letter_filename}.png`
							else
								`convert -background "#FFFFFF" -fill black -font #{Dir.pwd}/fonts/#{font}/#{font_info["font_file"]} -trim -antialias -pointsize 300 label:"\\#{letter}" #{config["build_path"]}/builds/tmp/#{font}_#{letter_filename}.png`
							end
							totals << [letter, "#{config["build_path"]}/builds/tmp/#{font}_#{letter_filename}.png", "B0", "W0", "%"]

							if File.exists?("#{config["build_path"]}/builds/tmp/#{font}_#{letter_filename}.png") == false
								totals.last[2] = "ERROR"
								totals.last[3] = "ERROR"
								totals.last[4] = "ERROR"
							else
								image = ChunkyPNG::Image.from_file("#{config["build_path"]}/builds/tmp/#{font}_#{letter_filename}.png")

								width = image.dimension.width
								height = image.dimension.height

								puts letter
								puts width
								puts height
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
								puts black_pixels
								puts white_pixels
								totals.last[4] = ((black_pixels.to_f/(black_pixels.to_f + white_pixels.to_f)) * 100)
								quick_totals << totals.last[4]
								puts totals.last[4]
							end
						end

						File.open("#{config["build_path"]}/builds/assets/#{font}/font_weight_simple.json", 'w') { |file| file.write("#{quick_totals.to_json}")}
						File.open("#{config["build_path"]}/builds/assets/#{font}/font_weight.json", 'w') { |file| file.write("#{totals.to_json}")}
					end
				end
			else
				font_pass_test == false
				puts "Failed 1"
			end
		else
			font_pass_test == false
			puts "Failed Test 2"
		end
	else
		##User has explicitly excluded font
		font_pass_test == false
		puts "Blacklisted"
	end
	if config["whitelist"].include?("#{font}")
		##User has explicitly whitelisted font so continue on even if it failed above
		font_pass_test == true
		puts "Whitelisted"
	end
	if font_pass_test == false
		`rm -rf #{config["build_path"]}/builds/assets/#{font}`
		`mkdir #{config["build_path"]}/builds/assets/#{font}`
		File.open("#{config["build_path"]}/builds/assets/#{font}/failed_to_test", 'w') { |file| file.write("Font Failed To Pass The Test Criteria")}
	else
		##Copy File To Build
		`cp #{Dir.pwd}/fonts/#{font}/#{font_info["font_file"]} #{config["build_path"]}/builds/assets/#{font}/#{font_info["font_file"]}`

		##Build HTML Font Page
		html_page = ["<!DOCTYPE html><html><head><title>#{config["html_title"]} #{font}</title></head><body><div><a href=\"/\">Back To Font Index</a></div><div>"]
		html_page << "<h1>#{font_info["name"]}</h1>"
		html_page << ""
		html_page << "<h3>Normal</h3><img src=\"normal.svg\"/> <h3>Bold</h3><img src=\"bold.svg\"/> <h3>Italic</h3><img src=\"italic.svg\"/>"
		html_page << "<p>#{config["gen_domain"]}/assets/#{font}/#{font_info["font_file"]}</p>"
		html_page << "<h3>Licence: #{font_info["licence"]}</h3><p>#{Kramdown::Document.new(File.read("#{Dir.pwd}/fonts/#{font}/licence.md")).to_html}"
		html_page << "</div><div><p>Current Version: #{font_info["repo_version"]}<br /> Build Finished #{Time.now}</p>#{config["gen_disclamer"]}</p></div></body></html>"
		html_page << "</div></body></html>"
		File.open("#{config["build_path"]}/builds/assets/#{font}/index.html", 'w') { |file| file.write("#{html_page.join("")}")}
		##Add Link to page in Index
		index_page << "<a href=\"assets/#{font}/index.html\">#{font_info["name"]} | #{font_info["licence"]} |</a><br />"
		json_index_page << "\"#{font}\":{\"info\": #{font_info.to_json.to_s}, \"normal_preview\": \"#{config["gen_domain"]}/assets/#{font}/normal.svg\", \"bold_preview\": \"#{config["gen_domain"]}/assets/#{font}/bold.svg\", \"italic_preview\": \"#{config["gen_domain"]}/assets/#{font}/italic.svg\", \"formated_licence\": \"#{CGI.escape Kramdown::Document.new(File.read("#{Dir.pwd}/fonts/#{font}/licence.md")).to_html}\", \"path_to_font\": \"#{config["gen_domain"]}/assets/#{font}/#{font_info["font_file"]}\", \"font_weight_analysis\":#{quick_totals.to_json}},"
	end
	##Write the version number to the text file so that next time it will not parse again.
	File.open("#{config["build_path"]}/builds/assets/#{font}/version.txt", 'w') { |file| file.write("#{font_info["repo_version"]}")}
end
index_page << "</div></body></html>"
File.open("#{config["build_path"]}/builds/index.html", 'w') { |file| file.write("#{index_page.join("")}")}
json_index_page << "\"git_version\": \"#{downloaded_version}\", \"time_complete\":\"#{Time.now}\"}"
File.open("#{config["build_path"]}/builds/index.json", 'w') { |file| file.write("#{json_index_page.join("")}")}
