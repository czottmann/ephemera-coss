#
#  SingleArticleFiles.rb
#  Ephemera
#
#  Created by Carlo Zottmann on 24.01.10.
#  Copyright (c) 2010 Carlo Zottmann. All rights reserved.
#

# require "mobi"


module Instapaper

  class SingleHtmlFile

    include Logging


    def self.generate( hash = {} )
      log("generate")
      id      = hash[:id]
      title   = hash[:title]
      article = hash[:article]

      filename =  "#{APP_SUPPORT_TMPDIR}/[#{article.site}] " +
        title.gsub(/\//, "\u{E2 81 84}").gsub(/:/, "-") +
        ".#{id}.html"

      log("generate '#{filename}'")

      File.open(filename, "w") do |f|
        f.puts article.html
      end
    end
  
  end




  class SingleTxtFile

    include Logging


    def self.generate( hash = {} )
      log("generate")
      id      = hash[:id]
      title   = hash[:title]
      article = hash[:article]

      filename =  "#{APP_SUPPORT_TMPDIR}/[#{article.site}] " +
        title.gsub(/\//, "\u{E2 81 84}").gsub(/:/, "-") +
        ".#{id}.txt"

      File.open(filename, "w") do |f|
        f.puts article.html
      end
    end
  
  end




=begin
  class SingleMobiFile

    include Logging


    def self.generate( hash = {} )
      log("generate")
      id      = hash[:id]
      title   = hash[:title]
      article = hash[:article]
      site    = article.site + " "

      mobi = Mobi.new
      mobi.title   = title 
      mobi.name    = title
      mobi.content = article.html

      mobi.header.type     = "NEWS"
      mobi.header.encoding = "UTF-8"
      
      mobi.header.extended_headers << Mobi::ExtendedHeader.new( 100, site.unpack("C*") )
      mobi.header.extended_headers.each do |eh|
        mobi.header.exth_length += eh.length
      end

      mobi.header.exth_count = mobi.header.extended_headers.size

      mobi.write_file("#{APP_SUPPORT_TMPDIR}/#{id}.mobi")
    end
  
  end
=end

end