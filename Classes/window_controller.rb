#
#  WindowController.rb
#  Ephemera
#
#  Created by Carlo Zottmann on 06.01.10.
#  Copyright (c) 2010 Carlo Zottmann. All rights reserved.
#

require "controller"


class WindowController < Controller

  attr_accessor :main_window, :prefs_window, :about_window
  attr_accessor :outlet_sync_button, :outlet_prefs_button
  attr_accessor :delegate
  
  
  def applicationDidFinishLaunching(notification)
    self.main_window.setTitle(
      NSBundle.mainBundle.infoDictionary.objectForKey("CFBundleName").to_s +
      " " +
      NSBundle.mainBundle.infoDictionary.objectForKey("CFBundleVersion").to_s
    )
    
    @sb                = self.outlet_sync_button
    @pb                = self.outlet_prefs_button
    @original_sb_title = @sb.title
    @login_status      = false
    @ual               = nil
    @prefs_enabled     = true

    listen_for_notification("reader.error")
    listen_for_notification("reader.msg")
    
    listen_for_notification("unreadarticleslist.status")
    listen_for_notification("singlearticlesprocessor.status")
    listen_for_notification("premadebundlesprocessor.status")
    
    if ENV["AUTORUN"] && CONF.reader_auto_run?
      log("applicationDidFinishLaunching", "auto run")
      sync(nil)
    else
      notify("log.clear")
      holler(WELCOME_MESSAGE.strip)
      notify("log.scroll_to_top")
    end
  end


  def applicationWillTerminate(notification)
    log("applicationWillTerminate")
  end
  
  
  # Preferences-Menuitem (de-)aktivieren. Richtet sich nach dem Status des
  # Prefs-Buttons.
  # 
  # Die Methode wird aufgerufen, wenn im IB der "File's Owner" den
  # WindowController als Delegate hat, und gilt nur für die Menuitems, die
  # mit Methoden im Controller verknüpft sind.
  def validateMenuItem(menuItem)
    if menuItem.action == :"open_prefs_sheet:"
      return @prefs_enabled
    end
  end
  

  def open_prefs_sheet(sender)
    NSApp.beginSheet(
      prefs_window,
      modalForWindow: main_window,
      modalDelegate: nil,
      didEndSelector: nil,
      contextInfo: nil
    )
  end
  
  
  def sync(sender)
    log("sync")
    
    notify("log.clear")

    u = CONF.ip_username.password
    p = CONF.ip_password.password
    
    @login_status = false
    @ual          = nil
    @unread       = nil
    @reader       = nil
    
    if u.empty?
      holler("Ephemera needs your Instapaper username in order to work! (And your password, if you use one.)")
      open_prefs_sheet(self)
    else
      return unless Reader.new.exists?

      disable_sync_button
      holler("Checking Instapaper for your news...")

      log("sync", "login attempt")

      Instapaper::Login.new(u, p).login do |status|
        log("sync", "Login status: #{status.inspect}")

        @login_status = status[:valid]
        msg = nil
        
        if @login_status == true
          holler("Logged in successfully...")
          holler("Looking for your unread articles...")

          @ual = Instapaper::UnreadArticlesList.new
          @ual.fetch

        elsif status.has_key?(:error)
          msg = "Shenanigans! Ephemera couldn't log you in. The Fail Fairy says: #{ status[:error] }."
        else
          msg = "Whoops, it looks like your Instapaper credentials don't work! Better re-check for typos."
        end

        unless msg.nil?
          holler(msg)
          enable_sync_button
        end

      end
    end
    
  end


  def open_website_link(sender)
    log("open_website_link")
    open_url("http://goephemera.com/")
  end


  def open_gs_link(sender)
    log("open_gs_link")
    open_url("http://bit.ly/67PVI8")
  end
  
  
  def open_instapaper_link(sender)
    log("open_instapaper_link")
    open_url("http://bit.ly/5kuZ70")
  end


  # ====================== NOTIFICATION HANDLERS
        
  def unreadarticleslist_status(notification)
    case notification.userInfo[:s]
    when "no_unread" then
      holler("...and it turns out you have no unread articles! Well done, you!")
      Reader.new.unmount_device
      enable_sync_button
    when "done" then
      @unread = @ual.articles
      holler("...done!")

      if CONF.reader_format >= 10
        holler("Now fetching your unread articles. This might take a moment...")
        Instapaper::PremadeBundlesProcessor.new
      else
        holler("Archiving your read articles...")
        @reader = Reader.new
        archived_ids = @reader.process_single_articles_step1
        @ual.remove_archived(archived_ids)

        holler("Now fetching your #{@unread.list.size} unread articles... ", "", false)
        Instapaper::SingleArticlesProcessor.new(@unread.list)
      end
    when "error" then
      holler("An error occurred! The Fail Fairy says: #{ notification.userInfo[:e] }")
      enable_sync_button
    end
  end
  
  
  def singlearticlesprocessor_status(notification)
    case notification.userInfo[:s]
    when "fetched" then
      holler(". ", "", false)
    when "all_fetched" then
      holler("")
      holler("...done!")
      holler("")
      holler("Your list of unread articles:")
      
      id_list = []
      
      log("singlearticlesprocessor_status", "listing unread articles")

      @unread.list.each do |a|
        id_list << a[:id] 
        article = a[:article]
        msg = article.site + ": " + article.title
        holler(msg, "→")
        log("singlearticlesprocessor_status", "- " + a[:id].to_s + ": " + msg)
      end
      
      log("singlearticlesprocessor_status", "processing unread articles")

      @reader.process_single_articles_step2(id_list)
      enable_sync_button
    end
  end
  
  
  def premadebundlesprocessor_status(notification)
    case notification.userInfo[:s]
    when "all_fetched" then
      holler("...done!")
      
      log("premadebundlesprocessor_status", "processing bundle")

      Reader.new.process_bundled_article
      enable_sync_button
    end
  end

  
  def reader_error(notification)
    case notification.userInfo[:error]
    when "not_mounted" then
      msg = "Shenanigans! Ephemera couldn't find your reading device. Are you sure it's plugged into an USB port?"
    when "path_not_writable" then
      msg = "path_not_writable"
    when "prepare_path" then
      msg = "prepare_path"
    when "copy_articles" then
      msg = "copy_articles"
    end
    
    holler_error(msg)
  end
  
  
  def reader_msg(notification)
    message = notification.userInfo[:message]
  
    case message
    when "archiving" then
      holler(" ", "")
      msg = "Archiving %s read articles" % notification.userInfo[:number]
    when "done", "done_and_unmount" then
      holler(" ", "")
      msg = "ALL DONE — your unread Instapaper articles are waiting for you on your device. "
      msg += "It's been automatically unmounted so you can just unplug it. " if message == "done_and_unmount"
      msg += "Happy reading!"
    end
    
    holler(msg)
  end
  
  
protected
  
  def disable_sync_button
    @prefs_enabled = false
    
    @sb.setTitle("Working…")
    @sb.setEnabled(false)
    @pb.setEnabled(false)
  end
  
  
  def enable_sync_button
    @prefs_enabled = true
    
    @sb.setTitle(@original_sb_title)
    @sb.setEnabled(true)
    @pb.setEnabled(true)
  end


  def open_url(url)
    url = NSURL.URLWithString(url)
    NSWorkspace.sharedWorkspace.openURL(url)
  end

end
