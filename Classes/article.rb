#
#  Article.rb
#  Ephemera
#
#  Created by Carlo Zottmann on 11.01.10.
#  Copyright (c) 2010 Carlo Zottmann. All rights reserved.
#

require "constants"
require "data_fetcher"


module Instapaper

  class Article < DataFetcher

    attr_accessor :ip_id, :title, :site, :status, :html


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
      init_fetch
    end


    def connection(connection, didFailWithError: error)
      if super
        @status = { :error => error.localizedDescription }
        @html   = ""
        notify("article.fetched")
      end
    end
    
    
    def connectionDidFinishLoading(connection)
      super
      
      process_raw
      notify("article.fetched")
    end


  private

    # Wandelt die rohen Daten in HTML um, räumt das HTML auf, erzeugt einige
    # weitere Attribute (+@site+ etc.).
    
    def process_raw
      log("process_raw")
      error = Pointer.new_with_type("@")
      @doc = NSXMLDocument.alloc.initWithData(@data, options: NSXMLDocumentTidyHTML, error: error)

      if NSString.alloc.initWithData(@data, encoding: NSUTF8StringEncoding).empty?
        @html = ""
        return
       end

      # Titel etc. extrahieren
      @site = get_xpath_value_from_doc("//div[@class='sm']")
      
      # Unnützes Zeug löschen
      xpath_selectors = [
        "//style",
        "//link",
        "//meta",
        "//noscript",
        "//@*[local-name()='style']",
        "//div[contains(@class, 'top')]",
        "//div[contains(@class, 'bar')][1]"
      ].join("|")
      
      @doc.nodesForXPath(xpath_selectors, error: error).each { |n| n.detach }
      
      adjust_bottom_bar
      adjust_blockquotes
      
      @html = NSMutableString.alloc.initWithData(@doc.XMLData, encoding: NSUTF8StringEncoding)
    end


    def get_xpath_value_from_doc(xpath_selector)
      error = Pointer.new_with_type("@")
      value = @doc.nodesForXPath(xpath_selector, error: error).first.objectValue rescue ""
      normalize_string(value)
    end


    def adjust_bottom_bar
      error = Pointer.new_with_type("@")
      bb = @doc.nodesForXPath("//div[contains(@class, 'bottom')] | //div[contains(@class, 'bar')]", error: error).first
      
      return if bb.nil?
      
      bb.setChildren(nil)

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
        
        bb.insertChild(node, atIndex: i)
      end
    end


    def adjust_blockquotes
      error = Pointer.new_with_type("@")
      @doc.nodesForXPath("//blockquote/p", error: error).each do |node|
        node.setName("div")
      end
    end


    def normalize_string(string)
      string.gsub(/<[^>]*>/, " ").squeeze(" ").strip
    end

  end

end

