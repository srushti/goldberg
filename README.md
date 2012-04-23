<a href='http://ci.c42.in/projects/goldberg'><img src='http://ci.c42.in/projects/goldberg.png' alt='Goldberg Build Status'></a>

# Goldberg

Goldberg is a lightweight Continuous Integration Server that works for any language. 
It also supports RVM and Bundler for Ruby Projects. 

Visit [ci.c42.in][] to see a live Goldberg server.

### Installation

Please refer to INSTALLATION.md
       
### Desktop Notification of Build Status

Goldberg generates feeds that work with all CruiseControl-compatible monitors like [CCMenu (mac)][], [BuildNotify (linux)][] & CCTray (windows). The feed is located in the root and is named `cc.xml`. eg: [cc.xml](http://ci.c42.in/cc.xml)

### Help

      # To get man page style help
      ./bin/goldberg help [command]

### Talking to us

We are very helpful people - please add an Issue to http://github.com/c42/goldberg/issues if you find a bug, or reach us through any of the following channels:

-   Twitter: [@GoldbergCI](http://twitter.com/GoldbergCI 'GoldbergCI')
-   IRC: #goldberg
-   email: goldberg@c42.in

## Contributors

See CONTRIBUTORS.MD

  [C42 Engineering]: http://c42.in
  [CruiseControl.rb]: https://github.com/thoughtworks/cruisecontrol.rb
  [ci.c42.in]: http://ci.c42.in
  [Bundler]: http://gembundler.com/
  [CCMenu (mac)]: http://ccmenu.sourceforge.net/
  [BuildNotify (linux)]: https://bitbucket.org/Anay/buildnotify/wiki/Home
  [ci.c42.in/XmlStatusReport.aspx]: http://ci.c42.in/XmlStatusReport.aspx

© Copyright 2010–2011 [C42 Engineering][]. All Rights Reserved.