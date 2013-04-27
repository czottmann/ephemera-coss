namespace :debug do

  namespace :prefs do

    desc "Löscht die Settings."
    task :remove do
      fn = File.expand_path("Library/Preferences/de.municode.Ephemera.plist", "~")
      File.delete(fn)
    end

  end

  namespace :log do

    desc "Behält das Logfile im Auge"
    task :tail do
      fn = File.expand_path("Library/Application Support/Ephemera/run.log", "~")
      system("tail -f '#{fn}'")
    end

  end
end

  
namespace :app do
  
  desc "Packt das aktuelle Release"
  task :tgz do
    fn = "Ephemera_" + Time.now.strftime("%Y%m%d_%H%M%S") + ".tgz"
    system("cd build/Release/ && tar czpf #{fn} Ephemera.app")
  end

  desc "Packt das aktuelle Release und verschiebt das File zu Dropbox"
  task :tgz_to_dropbox do
    fn = "Ephemera_" + Time.now.strftime("%Y%m%d_%H%M%S") + ".tgz"
    dropbox = "~/Dropbox/Public/Ephemera/"
    cmd = [
      "cd build/Release/",
      "tar czpf #{fn} Ephemera.app",
      "mv #{fn} #{dropbox}",
      "open #{dropbox}",
      "echo http://dl.dropbox.com/u/7298/Ephemera/#{fn}"
    ].join(" && ")
    
    system(cmd)
  end

end


namespace :mr do
  namespace :system do

    MR_OFF_DIR = "/Library/Frameworks/_deactivated_MacRuby"

    desc "Deaktiviert MacRuby.framework in /Library/Frameworks/"
    task :off do
      if File.exists?("/Library/Frameworks/MacRuby.framework")
        system("sudo mkdir -p #{MR_OFF_DIR} && sudo mv /Library/Frameworks/MacRuby.framework #{MR_OFF_DIR}/MacRuby.framework")
      end
    end
    
    desc "Aktiviert MacRuby.framework in /Library/Frameworks/"
    task :on do
      if File.exists?("#{MR_OFF_DIR}/MacRuby.framework")
        system("sudo mv #{MR_OFF_DIR}/MacRuby.framework /Library/Frameworks/")
      end
    end

  end
end