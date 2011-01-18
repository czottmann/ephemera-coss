#
#  AboutController.rb
#  Ephemera
#
#  Created by Carlo Zottmann on 16.01.10.
#  Copyright (c) 2010 Carlo Zottmann. All rights reserved.
#

require "controller"


class AboutController < Controller

  attr_accessor :about_window, :outlet_about_field
  
  
  def awakeFromNib
    super
    
    filename = NSBundle.mainBundle.resourcePath.fileSystemRepresentation + "/about.rtf"
    s = NSAttributedString.alloc.initWithPath( filename, documentAttributes: Pointer.new_with_type("@") )

    r = NSRange.new( @outlet_about_field.textStorage.length, 0 )
    @outlet_about_field.textStorage.replaceCharactersInRange( r, withAttributedString: s )
  end
  
end
