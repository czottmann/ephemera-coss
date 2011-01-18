#
#  config.rb
#  Ephemera
#
#  Created by Carlo Zottmann on 27.01.10.
#  Copyright (c) 2010 Carlo Zottmann. All rights reserved.
#

class Config

  PREF = NSUserDefaults.standardUserDefaults


  def initialize
    unless defined?(DEFAULTS)
      raise ArgumentError, "DEFAULTS isn't set"
    end
    
    define_config_methods
    register_defaults
  end


  def define_config_methods
    # Booleans
    DEFAULTS[:booleans].each do |o|
      m, default = *o
      
      self.class.send( :define_method,
        "#{m}?".to_sym,
        Proc.new { PREF.boolForKey(m) }
      )

      self.class.send( :define_method,
        "#{m}!".to_sym,
        Proc.new { |bool| PREF.setObject(bool, forKey: m) }
      )
    end
    
    # Strings
    DEFAULTS[:strings].each do |o|
      m, default = *o
      
      self.class.send( :define_method,
        "#{m}".to_sym,
        Proc.new { PREF.stringForKey(m) }
      )
      
      self.class.send( :define_method,
        "#{m}=".to_sym,
        Proc.new { |text| PREF.setObject(text.to_s, forKey: m) }
      )
    end

    # Nummern
    DEFAULTS[:integers].each do |o|
      m, default = *o
      
      self.class.send( :define_method,
        "#{m}".to_sym,
        Proc.new { PREF.integerForKey(m) }
      )
      
      self.class.send( :define_method,
        "#{m}=".to_sym,
        Proc.new { |int| PREF.setObject(int.to_i, forKey: m) }
      )
    end

    # Credentials
    DEFAULTS[:credentials].each do |o|
      service, prefix, single_credentials = *o

      if single_credentials

        %w( username password ).each do |key|
          self.class.send( :define_method,
            "#{prefix}_#{key}".to_sym,
            Proc.new {
              EMGenericKeychainItem.genericKeychainItemForService(service, withUsername: key)
            }
          )

          self.class.send( :define_method,
            "#{prefix}_#{key}=".to_sym,
            Proc.new { |text|
              existing_item = self.send("#{prefix}_#{key}")

              if existing_item.nil?
                EMGenericKeychainItem.addGenericKeychainItemForService(
                  "Ephemera",
                  withUsername: key,
                  password: text.to_s
                )
              else
                existing_item.setPassword(text.to_s)
              end
            }
          )
        end
        
      else
      
        # Gibt bei Erfolg ein +EMGenericKeychainItem+ (hat <tt>#username</tt>,
        # <tt>:password</tt>) zurück.
        # Erwartet einen +String+ mit dem Usernamen.
        # Erzeugt +ArgumentError+ bei fehlendem/leerem Parameter.

        self.class.send( :define_method,
          "#{prefix}_credentials".to_sym,
          Proc.new { |un|
            EMGenericKeychainItem.genericKeychainItemForService(service, withUsername: un.to_s)
          }
        )

        # (Über-)Schreibt einen Keychain-Eintrag für Service "Ephemera".
        # Erwartet ein +Hash+ mit den Keys <tt>:username</tt> und <tt>:password</tt>.
        # Gibt bei Erfolg ein +EMGenericKeychainItem+ (hat <tt>#username</tt>,
        # <tt>:password</tt>) zurück.

        self.class.send( :define_method,
          "#{prefix}_credentials=".to_sym,
          Proc.new { |opts|
            opts ||= {}
            c = { :username => "", :password => "" }.merge(opts)
            c[:username] = c[:username].to_s
            c[:password] = c[:password].to_s
            
            # if c[:username].to_s.empty?
            #   raise ArgumentError, "Username can't be blank"
            # end

            existing_item = self.ip_credentials( c[:username] )

            if existing_item.nil?
              EMGenericKeychainItem.addGenericKeychainItemForService(
                "Ephemera",
                withUsername: c[:username],
                password: c[:password]
              )
            else
              existing_item.setPassword( c[:password] )
            end
          }
        )
      end
    end
  end
  
  
  # Registriert die Default-Werte im System -- überträgt die Daten aus
  # +DEFAULTS+ in die <tt>NSUserDefaults.standardUserDefaults</tt>.
  def register_defaults
    default_values = {}
    
    d = DEFAULTS.dup
    d.delete(:credentials)
    
    d.values.flatten(1).each do |d|
      default_values[ d[0] ] = d[1]
    end
    
    PREF.registerDefaults(default_values)
  end
  
  
  # Gibt Array mit den Sub-Keys in +DEFAULTS+ zurück.
  def defaults_keys
    d = DEFAULTS.dup
    d.delete(:credentials)
    d.values.flatten(1).keys
  end
  
  
  # Gibt Array mit den Sub-Keys in +DEFAULTS+ zurück.
  def defaults_structure
    d = DEFAULTS.dup
    d.each do |k, v|
      d[k] = v.collect { |i| k == :credentials ? i[1] : i.first }
    end
    
    d
  end
  
  
  # Schreibt die Config auf Disk.
  def write!
    PREF.synchronize
  end
  
end


CONF = Config.new


