#
#  SingleArticlesProcessor.rb
#  Ephemera
#
#  Created by Carlo Zottmann on 20.01.10.
#  Copyright (c) 2010 Carlo Zottmann. All rights reserved.
#

require "notifiable"
require "single_article_files"


module Instapaper

  class SingleArticlesProcessor

    include Notifiable
    include Logging
    
    attr_accessor :id_list
    
    
    # Erwartet ein Array mit Hashes á la
    # <tt>{ :id => 123, :title => "Titel", :article => nil }</tt>.
    #
    # *N<* +article.fetched+
    def initialize( id_list = [] )
      @id_list = id_list
      @fetched = 0
      @format  = [nil, "mobi", "epub", "html", "txt"][CONF.reader_format]

      @open_connections = 0
      @list_index       = 0
      @done             = false
      
      # Nur +super+ funktioniert nicht, weil das Original-Argument mit 
      # übergeben wird, was dieses +initialize+ nicht erwartet.
      super()

      listen_for_notification("article.fetched")

      fetch_articles unless @id_list.empty?
    end


    # Triggert das Laden der einzelnen Artikel.
    def fetch_articles
      log("fetch_articles")

      # `while`-loop erzeugte anscheinend ein Scoping-Problem - die Notifications
      # wurden nie getriggert.
      # TODO: Bugreport im MacRuby-Trac
      
      (3 - @open_connections).times do
        if @list_index < @id_list.size
          a = @id_list[@list_index]

          # NSLog("Queue fetch: #{a[:id]}")

          a[:article] = Article.new( a[:id], a[:title] )
          a[:article].fetch

          @open_connections += 1
          @list_index += 1
        end
      end
    end


    # Callback: Einzelner Artikel wurde fertig geladen.
    #
    # *N>* +singlearticlesprocessor.status+ ("fetched", "all_fetched")
    def article_fetched(notification)
      log("fetch_articles")

      @fetched += 1
      @open_connections -= 1
      notify( "singlearticlesprocessor.status", { :s => "fetched" } )
      
      if @id_list.size > @fetched
        fetch_articles
      else
        return if @done
        
        @id_list.delete_if { |a| a[:article].status.has_key?(:error) }
        
        log("fetch_articles", "#{@id_list.size} articles fetched")

        # TMP-Dateien anlegen
        @id_list.each do |a|
          Instapaper.const_get("Single#{@format.capitalize}File").generate(a)
        end
        
        log("fetch_articles", "All articles converted")
        
        notify( "singlearticlesprocessor.status", { :s => "all_fetched" } )
        @done = true
      end
    end

  
  end

end
