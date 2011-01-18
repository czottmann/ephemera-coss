#
#  PremadeBundleFile.rb
#  Ephemera
#
#  Created by Carlo Zottmann on 21.01.10.
#  Copyright (c) 2010 Carlo Zottmann. All rights reserved.
#

module Instapaper

  class PremadeBundleFile
  
    include Logging
    

    def self.generate( data = NSData.new, format = "mobi" )
      log("generate")
      data.writeToFile("#{APP_SUPPORT_TMPDIR}/instapaper.1.#{format}", atomically: true)
    end
  
  end

end