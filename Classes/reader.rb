#
#  Reader.rb
#  Ephemera
#
#  Created by Carlo Zottmann on 15.01.10.
#  Copyright (c) 2010 Carlo Zottmann. All rights reserved.
#

require "fileutils"
require "yaml"

require "constants"
require "notifiable"
require "article_archiver"


class Reader

  include Notifiable
  include Logging
  

  # Initalisiert die wichtigsten Variablen und archiviert bereits gelesene
  # Artikel auf Instapaper.com.
  def process_single_articles_step1
    log("proc_sa_1")
    return unless exists?

    @yaml_filename        = "id_list.yaml"
    @ids_stored_on_device = get_ids_stored_on_device
    @ids_left_on_device   = get_ids_left_on_device

    log("proc_sa_1", "ids_stored_on_device: #{@ids_stored_on_device.inspect}")
    log("proc_sa_1", "ids_left_on_device: #{@ids_left_on_device.inspect}")

    purge_bundled_articles_from_reader
    return archive_read!
  end
  

  # Verarbeitet Einzelartikel. Erwartet ein Array mit IDs.
  #
  # *N>* +reader.msg+ ("done", "done_and_unmount")
  def process_single_articles_step2( id_list = [] )
    log("proc_sa_2")
    return unless exists?

    @ids_unread_from_instapaper = id_list.map(&:to_i)
    log("proc_sa_2", "ids_unread_from_instapaper: #{@ids_unread_from_instapaper.inspect}")

    delete_remotely_archived
    move_articles_to_reader
    store_ids_to_read_on_device
    
    msg = unmount_device ? "done_and_unmount" : "done"
    
    log("proc_sa_2", msg)
    notify("reader.msg", { :message => msg } )
  end
  

  # Verarbeitet Bundles.
  #
  # *N>* +reader.msg+ ("done", "done_and_unmount")
  def process_bundled_article
    log("process_bundled_article")
    return unless exists?

    purge_single_articles_from_reader
    delete_files_for_id(1)
    move_articles_to_reader
    
    msg = unmount_device ? "done_and_unmount" : "done"
    
    log("process_bundled_article", msg)
    notify("reader.msg", { :message => msg } )
  end


  # Wirft das Device aus.
  # Gibt Bool zurück: +true+, wenn es sich um ein Device handelt und
  # Auto-Unmount aktiviert ist.
  def unmount_device
    log("unmount_device")
    if is_device? && CONF.reader_auto_unmount?
      s = [
        "tell application \"Finder\"",
        "  eject \"#{device_name}\"",
        "end tell",
        "delay 2",
        "do shell script \"mount > '#{APP_SUPPORT_DIR}/mounts.old'\""
      ].join("\n")
      NSAppleScript.alloc.initWithSource(s).executeAndReturnError(Pointer.new_with_type("@"))

      return true
    end

    return false
  end

  # Checkt, ob es das Zielverzeichnis gibt. Gibt Bool zurück.
  #
  # *N>* +reader.error+ ("not_mounted", "path_not_writable")
  def exists?
    if is_device? && !is_mounted?
      msg = "not_mounted"
      log("exists?", msg)
      notify( "reader.error", { :error => msg } )
      return false
    end
    
    unless path_writable?
      msg = "path_not_writable"
      log("exists?", msg)
      notify( "reader.error", { :error => msg } )
      return false
    end
    
    true
  end
  

  # Existiert das Device unter /Volumes/xyz überhaupt? Gibt Bool zurück.
  def is_mounted?
    is_device? ? File.exists?(device_path.to_s) : true
  end
  

  # Meldet, ob der Pfad auf ein Device zeigt. Gibt Bool zurück.
  def is_device?
    !device_path.nil?
  end

  
  # Gibt String ("/Volumes/xyz") zurück, wenn der Pfad auf ein Device zeigt,
  # sonst +nil+.
  def device_path
    path.match(/^(\/Volumes\/[^\/]*)/)[1] rescue nil
  end
  
  
  # Gibt String ("xyz") zurück, wenn der Pfad auf ein Device zeigt,
  # sonst +nil+.
  def device_name
    path.match(/^\/Volumes\/([^\/]*)/)[1] rescue nil
  end
  
  
  # Archiviert die gelesenen Artikel bei Instapaper und löscht sie sowohl vom
  # Device als auch aus dem tmp-Verzeichnis (so vorhanden). Gibt Liste der
  # archivierten IP-IDs zurück.
  #
  # *N>* +reader.msg+ ("archiving")
  def archive_read!
    log("archive_read!")
    @ids_to_archive = @ids_stored_on_device - @ids_left_on_device
    n = @ids_to_archive.size

    if n > 0
      log("archive_read!", "archiving #{n}: #{@ids_to_archive.inspect}")
      notify("reader.msg", { :message => "archiving", :number => n } )
    end
    
    @ids_to_archive.each do |id|
      Instapaper::ArticleArchiver.new(id).archive
      delete_files_for_id(id)
      delete_tmp_files_for_id(id)
    end
    
    @ids_to_archive
  end
  
  
protected

  # Gibt String mit vollständigem Pfad zurück (inkl. Ephemera-Verzeichnis).
  def path
    CONF.reader_path + "/_ephemera"
  end
  
  
  # Gibt den Pfadnamen der Artikelliste auf dem Device als String
  # zurück.
  def list_filename
    "#{path}/#{@yaml_filename}"
  end
  
  
  # Liest die Liste der noch existierenden Files auf dem Device aus und
  # extrahiert die IDs. Gibt Array zurück.
  def get_ids_left_on_device
    log("get_ids_left_on_device")
    Dir.entries(path).grep(/\.\d+\./).collect { |fn|
      fn.gsub(/^.+\.(\d+)\.[^\.]+$/, '\1').to_i
    }.uniq
  end
  
  
  # Löscht Files, die irgendwie anders archiviert worden sind, vom Device.
  def delete_remotely_archived
    log("delete_remotely_archived")
    ( @ids_left_on_device - @ids_unread_from_instapaper ).each do |id|
      delete_files_for_id(id)
    end
  end


  # Löscht alle Files mit einer bestimmten ID im Namen.
  def delete_files_for_id(id)
    FileUtils.rm_rf( Dir.glob("#{path}/*.#{id}.*") )
  end
  
  
  # Löscht alle Files mit einer bestimmten ID im Namen aus +APP_SUPPORT_TMPDIR+.
  def delete_tmp_files_for_id(id)
    FileUtils.rm_rf( Dir.glob("#{APP_SUPPORT_TMPDIR}/*.#{id}.*") )
  end
  
  
  # Verschiebt alle verbliebenen Dateien aufs Device.
  def move_articles_to_reader
    log("move_articles_to_reader")
    FileUtils.mv( Dir.glob("#{APP_SUPPORT_TMPDIR}/*"), path, { :force => true } )
  end
  
  
  # Liest das YAML-File aus und speichert die Daten in <tt>@ids_stored_on_device</tt>.
  def get_ids_stored_on_device
    log("get_ids_stored_on_device")
    if File.exists?(list_filename)
      YAML.load( File.open(list_filename) ) rescue []
    else
      []
    end
  end
  
  
  # Schreibt <tt>@ids_stored_on_device</tt> in das YAML-File.
  #
  # *N>* +reader.error+
  def store_ids_to_read_on_device
    log("store_ids_to_read_on_device")
    unless path_writable?
      msg = "path_not_writable"
      log("store_ids_to_read_on_device", msg)
      notify( "reader.error", { :error => msg } )
      return
    end
    
    File.open( list_filename, "w" ) do |f|
      f.puts @ids_unread_from_instapaper.to_yaml
    end
  end
  
  
  # Der Pfad wird hier angelegt, aber in erster Linie wird geprüft, ob er
  # schreibbar ist. Gibt Bool zurück.
  def path_writable?
    prepare_path if is_mounted?
    File.writable?(path)
  end
  

  # Legt den Pfad an.
  #
  # *N>* +reader.error+
  def prepare_path
    log("prepare_path")
    FileUtils.mkdir_p(path) unless Dir.exist?(path)
  rescue Exception => e
    log("prepare_path", "ERROR #{e}")
    notify( "reader.error", { :error => "prepare_path" } )
  end
  
  
  # Löscht alle Bundles vom Reader.
  def purge_bundled_articles_from_reader
    log("purge_bundled_articles_from_reader")
    to_purge = Dir.glob("#{path}/*").grep(/\/bundled\.\d\.\w+$/)
    FileUtils.rm_rf(to_purge)
  end
  
  
  # Löscht alle Einzelartikel vom Reader.
  def purge_single_articles_from_reader
    log("purge_single_articles_from_reader")
    to_purge = Dir.glob("#{path}/*").grep(/(\.\d{2,}\.\w+|id_list\.yaml)$/)
    FileUtils.rm_rf(to_purge)
  end
  
  
end
