#
#  PrefsController.rb
#  Ephemera
#
#  Created by Carlo Zottmann on 05.01.10.
#  Copyright (c) 2010 Carlo Zottmann. All rights reserved.
#

require "constants"
require "controller"
require "login"


class PrefsController < Controller
  
  # Outlets kann ich nicht dynamisch erzeugen, dann findet IB sie nicht. Meh!
  attr_accessor :outlet_ip_username, :outlet_ip_password
  attr_accessor :outlet_ip_test_button, :outlet_ip_test_output

  attr_accessor :outlet_reader_path, :outlet_reader_format
  attr_accessor :outlet_reader_auto_run, :outlet_reader_auto_unmount

  attr_accessor :prefs_window  

  
  def awakeFromNib
    super
    preset_settings_with_defaults
    
    @tb = self.outlet_ip_test_button
    @original_tb_title = @tb.title
  end
  
  
  def controlTextDidChange(note)
    # NSLog("Text field was changed")
  end
  
  
  def close_window(sender)
    log("close_window")

    NSApp.endSheet(prefs_window)
    prefs_window.orderOut(sender)
    preset_settings_with_defaults
  end


  # Öffnet das File-Panel für die Zielverzeichnis-Wahl.
  def browse_for_reader_folder(sender)
    dialog = NSOpenPanel.openPanel
    dialog.canChooseFiles = false
    dialog.canChooseDirectories = true
    dialog.allowsMultipleSelection = false
    
    if dialog.runModal == NSOKButton
      self.outlet_reader_path.stringValue = dialog.filenames.first
    end
  end
    

  def test_credentials(sender)
    log("test_credentials")
    
    u = self.outlet_ip_username.stringValue.to_s
    p = self.outlet_ip_password.stringValue.to_s

    if u.empty?
      update_test_status("You should enter your username!")
    else
      disable_test_button

      log("login attempt")

      Instapaper::Login.new( u, p ).login do |status|
        log("test_credentials", "Login status: #{status.inspect}")

        if status.has_key?(:error)
          msg = "There was an error: #{ status[:error] }"
        else
          if status[:valid] == true
            msg = "Valid credentials! You're good."
          else
            msg = "Whoops, it looks like your Instapaper credentials don't work! Better re-check for typos."
          end
        end
        
        update_test_status(msg)
        enable_test_button
      end
    end
  end
  
  
  def apply_settings(sender)
    log("apply_settings")

    CONF.defaults_structure.each do |section, keys|
      keys.each do |key|
        prefs_field = self.send("outlet_#{key}") rescue nil
        
        case section
        when :credentials then
          %w( username password ).each do |k|
            prefs_field = self.send("outlet_ip_#{k}") rescue nil
            v = CONF.send("ip_#{k}=", prefs_field.stringValue)
          end

        when :booleans then
          if prefs_field.class == NSButton
            checked = (prefs_field.state == 0) ? false : true
            CONF.send("#{key}!", checked)
          end
          
        when :strings then
          CONF.send("#{key}=", prefs_field.stringValue)
          
        when :integers then
          if prefs_field.class == NSPopUpButton
            CONF.send("#{key}=", prefs_field.selectedItem.tag)
          end
          
        end
      end
    end

    CONF.write!
    WorldDomination.new.launchagent(CONF.reader_auto_run?)
    
    # holler_settings
    close_window(sender)
  end


private

  # Setzt die Settings anhand der Defaults neu.
  def preset_settings_with_defaults
    log("preset_settings_with_defaults")

    CONF.defaults_structure.each do |section, keys|
      keys.each do |key|
        prefs_field = self.send("outlet_#{key}") rescue nil
        
        
        case section
        when :credentials then
          %w( username password ).each do |k|
            prefs_field = self.send("outlet_ip_#{k}") rescue nil
            v = CONF.send("ip_#{k}")
            prefs_field.setStringValue( v.nil? ? "" : v.password )
          end

        when :booleans then
          if prefs_field.class == NSButton
            prefs_field.setState( CONF.send("#{key}?") )
          end
          
        when :strings then
          prefs_field.setStringValue( CONF.send(key) )
          
        when :integers then
          if prefs_field.class == NSPopUpButton
            prefs_field.selectItemWithTag( CONF.send(key) )
          end
          
        end
      end
    end
    
    self.outlet_ip_test_button.setEnabled(true)
  end
  

  def update_test_status(text)
    @outlet_ip_test_output.stringValue = text
  end
  
  
protected
  
  def disable_test_button
    @tb.setTitle("Testing…")
    @tb.setEnabled(false)
  end
  
  
  def enable_test_button
    @tb.setTitle(@original_tb_title)
    @tb.setEnabled(true)
  end
  
end
