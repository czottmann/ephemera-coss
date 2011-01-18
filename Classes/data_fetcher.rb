#
#  DataFetcher.rb
#  Ephemera
#
#  Created by Carlo Zottmann on 11.01.10.
#  Copyright (c) 2010 Carlo Zottmann. All rights reserved.
#

require "notifiable"


module Instapaper

  class DataFetcher

    include Notifiable
    include Logging

    
    attr_accessor :request, :connection

    
    def initialize
      NSHTTPCookieStorage.sharedHTTPCookieStorage.setCookieAcceptPolicy(NSHTTPCookieAcceptPolicyAlways)
      init_attributes
    end
    
    
    def init_attributes
      @loading = false
      @request = nil
      @data    = NSMutableData.new
      @timeout = 10.0
      @retries = 0
    end
    
    
    def init_fetch
      @request = NSMutableURLRequest.requestWithURL(
        NSURL.URLWithString(@url), 
        cachePolicy: NSURLRequestReloadIgnoringCacheData,
        timeoutInterval: @timeout
      )
      
      @connection = NSURLConnection.connectionWithRequest(@request, delegate: self)
    end


    def connection(connection, didReceiveResponse: response)
      log("connection:didReceiveResponse")
      @data.setLength(0)
    end
    
    
    def connection(connection, didReceiveData:data)
      # NSLog("#{self.class}#didReceiveData")
      @data.appendData(data)
    end
    

=begin
    def connection(connection, willSendRequest: request, redirectResponse: redirect_response)
      NSLog("#{self.class}#redirectResponse (#{request.description})")

      new_request = request.mutableCopy
      @connection = NSURLConnection.connectionWithRequest(new_request, delegate: self)
      new_request
    end
=end


    def connection(connection, didFailWithError: error)
      log("connection:didFailWithError", error.localizedDescription)
      
      @loading = false
      
      if @retries < 2
        case error.localizedDescription
        when "unsupported URL", "The request timed out." then
          log("connection:didFailWithError", "retrying")
          @retries += 1
          init_fetch
          return false
        end
      end
      
      true
    end
    
    
    def connectionDidFinishLoading(connection)
      log("connectionDidFinishLoading", "length #{@data.length}")
      @loading = false
    end

  end

end
