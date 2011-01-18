#
#  Bootstrap.rb
#  Ephemera
#
#  Created by Carlo Zottmann on 23.01.10.
#  Copyright (c) 2010 Carlo Zottmann. All rights reserved.
#

require "logger"
require "fileutils"



APP_SUPPORT_DIR    = File.expand_path("Library/Application Support/Ephemera", "~")
APP_SUPPORT_TMPDIR = APP_SUPPORT_DIR + "/tmp"


# Anlegen von ~/Library/Application Support/Ephemera/...

unless Dir.exist?(APP_SUPPORT_TMPDIR)
  NSLog("Creating folder #{APP_SUPPORT_TMPDIR}")
  FileUtils.mkdir_p(APP_SUPPORT_TMPDIR)
end


RBLog = Logger.new("#{APP_SUPPORT_DIR}/run.log", 3, 1048576)
RBLog.datetime_format = "%Y.%m.%d %H:%M:%S"
RBLog.debug(" ")
RBLog.info("========== STARTING UP")
RBLog.info("========== VERSION " + NSBundle.mainBundle.infoDictionary.objectForKey("CFBundleVersion").to_s)
RBLog.info("========== BUILD " + NSBundle.mainBundle.infoDictionary.objectForKey("BuildTimestamp").to_s)


# Monkey patching
=begin
  module Kernel
    private
      
    # Gibt String mit dem Namen der aktuell ausgeführten Methode zurück.
    def this_method_name
      caller[2] =~ /`([^']*)'/ and $1
    end
  end
=end


# Logging vorbereiten

module LoggingClass
  def log(meth = "", string = "")
    msg = "#{self.name}##{meth}"
    msg += " -- #{string}" unless string.empty?
    RBLog.info(msg)
  end

  def log_error(meth = "", string = "")
    msg = "#{self.name}##{meth}"
    msg += " -- #{string}" unless string.empty?
    RBLog.error(msg)
  end
end

module Logging
  def self.included(mod)
    mod.extend LoggingClass
  end

  def log(meth = "", string = "")
    msg = "#{self.class}##{meth}"
    msg += " -- #{string}" unless string.empty?
    RBLog.info(msg)
  end

  def log_error(meth = "", string = "")
    msg = "#{self.class}##{meth}"
    msg += " -- #{string}" unless string.empty?
    RBLog.error(msg)
  end
end

