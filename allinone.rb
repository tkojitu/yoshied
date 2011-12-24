main_script = File.read("main.rb")
main_script.gsub!(/^require "([^"]+)"/) do
  filename = $1 + ".rb"
  File.read(filename)
end
File.open("yoshied.rb", "w"){|output| output.write(main_script)}
