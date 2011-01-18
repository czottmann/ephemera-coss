#
#  Constants.rb
#  Ephemera
#
#  Created by Carlo Zottmann on 14.01.10.
#  Copyright (c) 2010 Carlo Zottmann. All rights reserved.
#

DEFAULTS = {
  :credentials => [
    # [ Service, Prefix, single (true) oder paired ]
    ["Ephemera", "ip", true]
  ],
  :booleans => [
    ["reader_auto_run", false],
    ["reader_auto_unmount", false],
    ["first_run", true]
  ],
  :strings => [
    ["reader_path", "/Volumes/Kindle/documents"],
  ],
  :integers => [
    ["reader_format", 4]
  ]
}



WELCOME_MESSAGE = <<EOTEXT
Welcome to Ephemera, the Mac tool for Instapaper enthusiasts. It will synchronize your ebook reader with Instapaper.com using USB.


LOOKING FOR FEEDBACK!

Test and give feedback, please: bug reports, suggestions, general comments, ideas — anything. I'm a large, semi-muscular man, I can take it.

• Mail: feedback@goephemera.com 
• Support site: http://bit.ly/67PVI8
• Website: http://goephemera.com


DISCLAIMER

• No guarantees. Things might break, people might cry. I'm not liable for anything. Use at your own risk.
• I'm not affiliated with or endorsed by Instapaper.com in any way. I'm just a huuuuuuuge fan, that's all.
EOTEXT