#
#  Controller.rb
#  Ephemera
#
#  Created by Carlo Zottmann on 05.01.10.
#  Copyright (c) 2010 Carlo Zottmann. All rights reserved.
#

require "constants"
require "notifiable"


class Controller

  include Notifiable
  include Logging
  

  def initialize
    log("initialize")
  end
  

  def awakeFromNib
    log("awakeFromNib")
  end


  # Convenience methods
  
  def holler(message, prefix = "", linebreak = true)
    # NSLog("Controller#holler: #{message}")
    t = ""
    t += (prefix + " ") unless prefix.empty?
    t += message
    t += "\n" if linebreak
    notify( "log.add", { :message => t } )
  end
  
  
  def holler_error(message, prefix = "•")
    notify( "log.add", { :error => "#{prefix} #{message}" } )
  end
  
end

