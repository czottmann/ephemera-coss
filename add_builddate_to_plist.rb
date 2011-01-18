#!/usr/local/bin/ruby

fn_plist = ARGV[0].to_s

unless File.exists?(fn_plist)
  puts "File doesn't exist!"
  exit
end

lines = File.readlines(fn_plist)
index = lines.find_index { |line| line.match(/<\/dict>/) }
if index
  lines.insert(index, "\t<key>BuildTimestamp</key>\n", "\t<string>#{Time.now}</string>\n")
end

File.open(fn_plist, "w") do |f|
  f.puts lines
end
