#
#  Article.rb
#  Ephemera
#
#  Created by Carlo Zottmann on 11.01.10.
#  Copyright (c) 2010 Carlo Zottmann. All rights reserved.
#

require "constants"
require "data_fetcher"
require "cgi"


module Instapaper

  class Article < DataFetcher

      attr_accessor :ip_id, :title, :site, :status, :html, :url


    def initialize(id, title = "")
      @ip_id   = id.to_i
      @title   = title
      @site    = ""
      @status  = {}

      @url     = "http://www.instapaper.com/go/#{id}/text"
      @html    = nil
      @retries = 0

      # Nur +super+ funktioniert nicht, weil das Original-Argument mit 
      # übergeben wird, was dieses +initialize+ nicht erwartet.
      super()
    end


    def done?
      !@loading
    end
    
    
    def filename_tmp
      
    end
  

    def fetch
      return if @loading
      log("fetch")

      @loading = true
      connection = init_fetch
    end


    def connection(connection, didFailWithError: error)
      log("connection:didFailWithError: " + @ip_id.to_s)
      if super
        @status = { :error => error.localizedDescription }
        @html   = ""
        notify("article.fetched")
      end
    end
    
    
    def connectionDidFinishLoading(connection)
      super
      log("connection:connectionDidFinishLoading: " + @ip_id.to_s)
      
      error = Pointer.new_with_type("@")
      doc = NSXMLDocument.alloc.initWithData(@data, options: NSXMLDocumentTidyHTML, error: error)
    
      if NSString.alloc.initWithData(@data, encoding: NSUTF8StringEncoding).empty?
        @html = ""
      else
        @html = process_raw doc, error
      end
        
      notify("article.fetched")
    end




    # Wandelt die rohen Daten in HTML um, räumt das HTML auf, erzeugt einige
    # weitere Attribute (+@site+ etc.).
    
    def process_raw(doc, error)
      result = NSXMLDocument.alloc.initWithXMLString("<html><body></body></html>", options: NSXMLDocumentTidyHTML, error: error)

      body = result.nodesForXPath("//body", error: error).first
      
      # Titel etc. extrahieren
      @site = get_xpath_value_from_doc(doc, "//*[@id='titlebar']/span/a")
      @title = get_xpath_value_from_doc(doc, "//h1")
       
      # Unnützes Zeug löschen - strip out redundant stuff
      xpath_selectors = [
        "//style",
        "//link",
        "//meta",
        "//script",
        "//noscript",
		"//img"
      ].join("|")
      
      doc.nodesForXPath(xpath_selectors, error: error).each { |n| n.detach }

        #adjust_blockquotes doc
      
      if doc.nodesForXPath("//h1", error: error).first.nil?
          log('process_raw:unexpected title format for ' + @title + "/" + @url)
      else
          title = doc.nodesForXPath("//h1", error: error).first.detach
          body.addChild(title)
      end
        
      if doc.nodesForXPath("//div[@id='story']", error: error).first.nil?
          log('process_raw:unexpected story format for ' + @url)
      else
          story = doc.nodesForXPath("//div[@id='story']", error: error).first.detach
          body.addChild(story)
          
          add_bottom_bar body
      end

      NSMutableString.alloc.initWithData(result.XMLData, encoding: NSUTF8StringEncoding)
    end

  private
    def get_xpath_value_from_doc(doc, xpath_selector)
      error = Pointer.new_with_type("@")
      value = doc.nodesForXPath(xpath_selector, error: error).first.objectValue rescue ""
      value = CGI.unescapeHTML(value)
      value = value.gsub('’','\'')
      normalize_string(value)
    end


    def add_bottom_bar(doc)
      tags = [
        ["hr"],
        ["p", "You're reading an Instapaper article which was copied to your reader by Ephemera, the Mac tool for IP enthusiasts. Delete this article on your reading device, and during the next sync it'll be archived on Instapaper.com."],
        ["p", "Have feedback about Ephemera? Send an email to feedback@goephemera.com."]
      ]
      
      tags.size.times do |i|
        n = tags[i][0]
        s = tags[i][1]
        
        if s
          node = NSXMLNode.elementWithName(n, stringValue: s)
        else
          node = NSXMLNode.elementWithName(n)
        end
        
        doc.addChild(node)
      end
    end


    def adjust_blockquotes doc
      error = Pointer.new_with_type("@")
      doc.nodesForXPath("//blockquote/p", error: error).each do |node|
        node.setName("div")
      end
    end


    def normalize_string(string)
      string.gsub(/<[^>]*>/, " ").squeeze(" ").strip
    end
  end
end

