#
#  LogController.rb
#  Ephemera
#
#  Created by Carlo Zottmann on 05.01.10.
#  Copyright (c) 2010 Carlo Zottmann. All rights reserved.
#

require "controller"


class LogController < Controller

  attr_accessor :log_output


  def initialize
    super

    listen_for_notification("log.clear")
    listen_for_notification("log.add")
    listen_for_notification("log.scroll_to_top")
  end
    

  def awakeFromNib
    super
    
    # Es funktioniert nicht richtig ohne diese Zeile. Keine Ahnung. :/
    3.times { holler("The Fail Fairy looks around!") }
    notify("log.clear")
    holler("Ephemera: feeding your ADD since 1872.")
  end


  def add_line( text, is_error = false )
    opts = { NSFontAttributeName => NSFont.fontWithName("Helvetica", size: 12) }
    opts.merge!( { NSForegroundColorAttributeName => NSColor.redColor } ) if is_error
    
    s = NSMutableAttributedString.alloc.initWithString(text, attributes: opts)

    r = NSRange.new(@log_output.textStorage.length, 0)
    @log_output.textStorage.replaceCharactersInRange(r, withAttributedString: s)
    
    r = NSRange.new(@log_output.textStorage.length, 0)
    @log_output.scrollRangeToVisible(r)
  end
  

  def log_add(notification)
    u = notification.userInfo
    
    if u.has_key?(:error)
      msg = u[:error]
      add_line(msg, true)
    else
      msg = u[:message]
      add_line(msg)
    end

    # log(msg)
  end
  

  def log_clear(notification)
    log("log_clear")
    r = NSRange.new( 0, @log_output.textStorage.length )
    @log_output.replaceCharactersInRange( r, withString: '' )
  end


  def log_scroll_to_top(notification)
    r = NSRange.new(0, 0)
    @log_output.scrollRangeToVisible(r)
  end
  
end
