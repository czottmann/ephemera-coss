#
# rb_main.rb
# Ephemera
#
# Created by Carlo Zottmann on 26.11.09.
# Copyright Carlo Zottmann 2009. All rights reserved.
#

framework "Cocoa"

if Dir.exist?( File.expand_path("MacRuby.framework", NSBundle.mainBundle.privateFrameworksPath) )
  $:.map! { |x| x.sub(/^\/Library\/Frameworks/, NSBundle.mainBundle.privateFrameworksPath) }
  $:.unshift(NSBundle.mainBundle.resourcePath.fileSystemRepresentation)
end

dir_path = NSBundle.mainBundle.resourcePath.fileSystemRepresentation
main     = File.basename(__FILE__, File.extname(__FILE__))

Dir.glob("#{dir_path}/gems/*").each do |g|
  $LOAD_PATH.unshift( File.join(g, "lib") )
end

rb_files = Dir.glob( File.join(dir_path, "*.{rb,rbo}") )
rb_files.map! { |x| File.basename( x, File.extname(x) ) }

%w( bootstrap constants config ).reverse.each do |f|
  file = rb_files.detect { |fn| fn.match(/^#{f}/) }
  rb_files.unshift(file) if file
end

rb_files.uniq!

rb_files.each do |path|
  require(path) if path != main
end

NSApplicationMain(0, nil)
