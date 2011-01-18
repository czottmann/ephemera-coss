#
#  ArticleArchiver.rb
#  Ephemera
#
#  Created by Carlo Zottmann on 15.01.10.
#  Copyright (c) 2010 Carlo Zottmann. All rights reserved.
#

require "constants"
require "data_fetcher"


module Instapaper

  class ArticleArchiver < DataFetcher

    def initialize(id)
      @ip_id = id.to_i
      @url   = "http://www.instapaper.com/skip/#{id}"
      
      # Nur +super+ funktioniert nicht, weil das Original-Argument mit 
      # übergeben wird, was dieses +initialize+ nicht erwartet.
      super()
    end
    
    
    def archive
      return if @loading
      
      log("archive")
      @loading = true
      init_fetch
    end

  end

end
