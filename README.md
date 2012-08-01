<a href='http://ci.c42.in/projects/goldberg'><img src='http://ci.c42.in/projects/goldberg.png' alt='Goldberg Build Status'></a>

# Goldberg

Goldberg is a lightweight Continuous Integration Server that works for any language. It also supports RVM and Bundler for Ruby Projects.

Visit [ci.c42.in][] to see a live Goldberg server.

### Installation

Please refer to INSTALLATION.md. More configuration options are in CONFIGURATION.md

### Desktop Notification of Build Status

Goldberg generates feeds that work with all CruiseControl-compatible monitors like [CCMenu (mac)][], [BuildNotify (linux)][] & CCTray (windows). The feed is located in the root and is named `cc.xml`. eg: [cc.xml](http://ci.c42.in/cc.xml)

### Help

      # To get man page style help
      ./bin/goldberg help [command]

### We are nice people, talk to us!

Please add an issue on http://github.com/c42/goldberg/issues if you find a bug, or reach us through the following channels for any help:

-   Twitter: [@GoldbergCI](http://twitter.com/GoldbergCI 'GoldbergCI')
-   email: goldberg@c42.in

Goldberg is brought to you by [C42 Engineering][]. We are also the people behind [RubyMonk][], the online interactive Ruby learning solution.

  [C42 Engineering]: http://c42.in
  [CruiseControl.rb]: https://github.com/thoughtworks/cruisecontrol.rb
  [ci.c42.in]: http://ci.c42.in
  [CCMenu (mac)]: http://ccmenu.sourceforge.net/
  [BuildNotify (linux)]: https://bitbucket.org/Anay/buildnotify/wiki/Home
  [RubyMonk]: http://rubymonk.com
  [Bundler]: http://gembundler.com/

### Why Goldberg?

It was an ironic reference to Rube Goldberg machines.

[![Goldberg](https://upload.wikimedia.org/wikipedia/en/8/88/Rubenvent.jpg "Rube Goldberg machine")](http://en.wikipedia.org/wiki/Rube_Goldberg_machine)
