#
#  UnreadArticlesList.rb
#  Ephemera
#
#  Created by Carlo Zottmann on 11.01.10.
#  Copyright (c) 2010 Carlo Zottmann. All rights reserved.
#

require "data_fetcher"
require "article"
require "ostruct"


module Instapaper

  class UnreadArticlesList < DataFetcher

    attr_accessor :articles
    

    # Erwartet ein Hash mit folgenden Keys:
    # * +:parent+: Aufrufendes Objekt
    # * +:callback+: Methode des Parents, die von +connectionDidFinishLoading+
    #   aufgerufen werden soll
    def initialize
      @url      = "http://www.instapaper.com/u"
      @fetched  = 0
      @articles = OpenStruct.new({
        :mobi => "http://www.instapaper.com/mobi",
        :epub => "http://www.instapaper.com/epub",
        :list => []
      })
      
      # Nur +super+ funktioniert nicht, weil das Original-Argument mit 
      # übergeben wird, was dieses +initialize+ nicht erwartet.
      super()
    end
    
    
    def fetch
      log("fetch")
      return if @loading
      @loading = true
      init_fetch
    end
    
    # *N>* +unreadarticleslist.status+ ("error")
    def connection(connection, didFailWithError: error)
      if super
        notify( "unreadarticleslist.status", { :s => "error", :e => error.localizedDescription } )
      end
    end
    
    
    # *N>* +unreadarticleslist.status+ ("no_unread", "done")
    def connectionDidFinishLoading(connection)
      super
      extract_articles_and_bundles

      if @articles.list.empty?
        log("connectionDidFinishLoading", "no_unread")
        notify( "unreadarticleslist.status", { :s => "no_unread" } )
      else
        log("connectionDidFinishLoading", "done")
        notify( "unreadarticleslist.status", { :s => "done" } )
      end
    end
    
    
    # Erwartet ein Array mit numerischen IDs. Die entsprechenden
    # <tt>@articles.list</tt>-Einträge werden dann entfernt.
    def remove_archived(archived_ids)
      @articles.list.delete_if { |a| archived_ids.include?( a[:id] ) }
    end
    
    
  protected
  
    def extract_articles_and_bundles
      log("extract_articles_and_bundles")

      if @articles.list.empty?       
        error = Pointer.new_with_type("@")
        doc   = NSXMLDocument.alloc.initWithData( @data, options: NSXMLDocumentTidyXML, error: error )
        links = doc.nodesForXPath( "//div[contains(@class, 'tableViewCell')]", error: error ) rescue []

        links.each do |l|
          node  = NSXMLDocument.alloc.initWithXMLString( l.XMLString, options: NSXMLDocumentTidyXML, error: error )
          first_subnode = node.nodesForXPath( "//a[@class='actionLink' and @title='Edit']/@href", error: error ).first
          
          next if first_subnode.nil?
          
          id    = first_subnode.stringValue.gsub(/[^\d]+/, "").to_i
          title = node.nodesForXPath( "//a[@class='tableViewCellTitleLink']", error: error ).first.stringValue.strip

          @articles.list << {
            :id => id.to_i,
            :title => title
          }
        end
      end
    end

  end

end