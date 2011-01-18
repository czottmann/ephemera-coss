#
#  Login.rb
#  Ephemera
#
#  Created by Carlo Zottmann on 11.01.10.
#  Copyright (c) 2010 Carlo Zottmann. All rights reserved.
#

require "data_fetcher"
require "cgi"


module Instapaper

  class Login < DataFetcher
    
    # +action+: String, entweder "testing" oder "working"
    def initialize( username, password )
      @auth = { :u => username, :p => password }
      @url = "http://www.instapaper.com/user/login"

      # Nur +super+ funktioniert nicht, weil das Original-Argument mit 
      # übergeben wird, was dieses +initialize+ nicht erwartet.
      super()
    end
    
    
    def login(&block)
      return if @loading
      
      log("login")

      @block   = block
      @loading = true
      @request = NSMutableURLRequest.requestWithURL(
        NSURL.URLWithString(@url), 
        cachePolicy: NSURLRequestReloadIgnoringCacheData,
        timeoutInterval: 10.0
      )

      @request.setHTTPMethod("POST")

      u = CGI.escape( @auth[:u].to_s )
      p = CGI.escape( @auth[:p].to_s )

      @request.setHTTPBody( "username=#{u}&password=#{p}".to_s.dataUsingEncoding(NSUTF8StringEncoding) )
      @connection = NSURLConnection.connectionWithRequest(@request, delegate: self)
    end


    def connection(connection, didFailWithError: error)
      if super
        status = {
          :valid => false,
          :error => error.localizedDescription
        }
        
        @block.call(status)
      end
    end
    
    
    # Gibt +true+ oder +false+ zurück an den Block zurück.
    def connectionDidFinishLoading(connection)
      super
      
      status = { :valid => check_for_successful_login }
      @block.call(status)
    end


  private

    # Testet das empfangene HTML auf fehlerhafte Eingaben.
    # Gibt entweder +true+ oder +false+ zurück.
    def check_for_successful_login
      NSString.alloc.initWithData( @data, encoding:NSUTF8StringEncoding ).match(/class="error"/i).nil?
    end
    
  end

end

