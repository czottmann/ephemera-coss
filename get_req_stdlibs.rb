#!/usr/local/bin/ruby

reqs = `grep "require " Classes/*.rb`.split("\n")
reqs.reject! { |l| l.match(/\#.*require /) }
reqs.map! { |l| l.match(/["'](.+)["']/)[1] }

files = Dir.glob("Classes/*.rb").map! { |l| l.match(/\/(.+)\.rb/)[1] }

stdlibs = (reqs - files)
stdlibs.each do |lib|
  file = "/Library/Frameworks/MacRuby.framework/Versions/Current/usr/lib/ruby/1.9.0/#{lib}.rb"
  next unless File.exists?(file)

  r = "grep 'require ' #{file}"
  r = `#{r}`
  r = r.split("\n")
  r.reject! { |l| l.match(/\#.*require /) }
  r.map! { |l| l.match(/["'](.+)["']/)[1] }

  r.each do |l|
    l.gsub!(/\.rb/, "")
    stdlibs << l if stdlibs.index(l).nil?
  end
end

puts stdlibs.map { |lib| "--stdlib #{lib}" }.join(" ").strip