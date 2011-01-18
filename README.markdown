# Ephemera

Two-way Instapaper.com sync for your ebook reader.
[Website](http://goephemera.com/)


## Preface, Warnings, Notes

I wrote Ephemera a) to learn MacRuby and b) to scratch an itch I had.  Since then the iPad was released, and the itch is gone -- I don't read news on my Kindle anymore.  Still, Ephemera has a good number of users, but even though I had planned to I simply don't have the time to develop it any further.  I don't feel like abandoning it (any further) so **I've decided to release its codebase as COSS (crappy open source software)**.

I've made [several blog posts](http://blog.zottmann.org/tagged/ephemera) about Ephemera and its development.

It's hacky and rather poorly documented, mostly in German.  The code is rather simple, though, so brave prospectors will be probably be safe.

The Distribution target contains Sparkle appcast generation and file upload.  The latter will not work because of missing Keychain entries (server passwords/keys), but I left it in for "demonstration purposes".

So, have at it if you want.  Pick it up and develop it further, and I guarantee you it'll be an adventure like you've never had it before!  You will laugh, you will cry, you will facepalm yourself repeatedly.


## Especially Noteworthy

1. If you take over and create a new version, feel free to give me a heads-up, and I'll pass the word on (link on the website, tweets etc.).
2. I won't provide support for the code, mostly due to a lack of spare time and energy.
3. I won't hand over either domain or Twitter account.


## Requirements

* MacRuby 0.6 (it was written with 0.6, I suppose to make it work with 0.7 there need to be some adjustments)
 

## Acknowledgements

Ephemera uses [EMKeychain](http://extendmac.com/EMKeychain/) (MIT-licensed) and [Sparkle](http://sparkle.andymatuschak.org/) (MIT-licensed).


## Author

Carlo Zottmann, carlo@zottmann.org, [municode.de](http://municode.de/), [blog](http://carlo.zottmann.org/), [carlo@github](http://github.com/carlo/)


## License

Excluding the above libraries the source code is licensed under the WTFPL…

               DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
                       Version 2, December 2004

    Copyright (C) 2004 Sam Hocevar
     14 rue de Plaisance, 75014 Paris, France
    Everyone is permitted to copy and distribute verbatim or modified
    copies of this license document, and changing it is allowed as long
    as the name is changed.

               DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
      TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

     0. You just DO WHAT THE FUCK YOU WANT TO.


…with two addendums:

1. Please don't name your version of the tool "Ephemera".  I obviously can't enforce this friendly request, but honoring it would generate lots of good karma, so please consider it.
2. Some acknowledgement would be nice.

