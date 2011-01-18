#
#  Notifiable.rb
#  Ephemera
#
#  Created by Carlo Zottmann on 15.01.10.
#  Copyright (c) 2010 Carlo Zottmann. All rights reserved.
#


module Notifiable

  NAPP = "de.municode.Ephemera"
  NC   = NSNotificationCenter.defaultCenter

  def notify( name, user_info = {} )
    name.gsub!(".", "_")
    NC.postNotificationName(name, object: NAPP, userInfo: user_info)
  end
  
  
  def listen_for_notification(name)
    name.gsub!(".", "_")
    NC.addObserver(self, selector: "#{name}:", name: name, object: NAPP)
  end

end
