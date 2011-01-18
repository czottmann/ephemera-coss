#
#  WorldDomination.rb
#  Ephemera
#
#  Created by Carlo Zottmann on 18.01.10.
#  Copyright (c) 2010 Carlo Zottmann. All rights reserved.
#


class WorldDomination

  include Logging


  def initialize
    @fsp         = NSBundle.mainBundle.resourcePath.fileSystemRepresentation
    @fn          = "de.municode.Ephemera.plist"
    @script_out  = File.expand_path("autorun.sh", APP_SUPPORT_DIR)
    @launchagent = File.expand_path("Library/LaunchAgents/#{@fn}", "~")
    @log         = File.expand_path("launchctl.log", APP_SUPPORT_DIR)
  end
  

  def launchagent( on = false )
    if on && Reader.new.is_device?
      launchscript_install
      launchagent_install
      launchctl_load
    else
      launchctl_unload
      launchagent_remove
      launchscript_remove
    end
  end
  
  
protected
  
  def launchctl_load
    log("launchctl_load")
    system("launchctl load '#{@launchagent}' >>'#{@log}' 2>&1")
  end
  
  
  def launchctl_unload
    log("launchctl_unload")
    system("launchctl unload '#{@launchagent}' >>'#{@log}' 2>&1")
  end
  
  
  def launchagent_install
    log("launchagent_install")
    xml = File.read( File.expand_path(@fn, @fsp) )
    xml.gsub!(/PATH/, @script_out)
    
    File.open(@launchagent, "w") do |f|
      f.puts xml
    end
  end

  
  def launchagent_remove
    log("launchagent_remove")
    system("rm -f '#{@launchagent}' >>'#{@log}' 2>&1")
  end
  

  def launchscript_install
    log("launchscript_install")
    p = File.expand_path("../../", @fsp)
    s = File.read( File.expand_path("autorun.bak.sh", @fsp) )
    s.gsub!(/%PATH%/, p)
    s.gsub!(/%DEVICE_PATH%/, Reader.new.device_path)
    s.gsub!(/%APP_SUPPORT_DIR%/, APP_SUPPORT_DIR)
    
    File.open(@script_out, "w") do |f|
      f.puts s
    end
    
    File.chmod(0755, @script_out)
    
    puts `mount > '#{APP_SUPPORT_DIR}/mounts.old'`
  end
  
  
  def launchscript_remove
    log("launchscript_remove")
    system("rm -f '#{@script_out}' >>'#{@log}' 2>&1")
  end

end
