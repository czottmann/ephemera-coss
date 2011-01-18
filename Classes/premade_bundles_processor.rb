#
#  PremadeBundlesProcessor.rb
#  Ephemera
#
#  Created by Carlo Zottmann on 21.01.10.
#  Copyright (c) 2010 Carlo Zottmann. All rights reserved.
#

require "data_fetcher"
require "premade_bundle_file"


module Instapaper

  class PremadeBundlesProcessor < DataFetcher
    
    
    def initialize
      super

      @format  = ["mobi", "epub"][ CONF.reader_format - 10 ]
      @url     = "http://www.instapaper.com/#{@format}"
      @timeout = 30.0
      init_fetch
    end


    # *N>* +premadebundlesprocessor.status+ ("error")
    def connection(connection, didFailWithError: error)
      if super
        notify( "premadebundlesprocessor.status", { :s => "error", :e => error.localizedDescription } )
      end
    end
    
    
    # Callback: Bundle wurde fertig geladen.
    #
    # *N>* +premadebundlesprocessor.status+ ("all_fetched")
    def connectionDidFinishLoading(connection)
      super
      
      # TMP-Datei anlegen
      Instapaper::PremadeBundleFile.generate(@data, @format)
      notify( "premadebundlesprocessor.status", { :s => "all_fetched" } )
    end

  
  end

end