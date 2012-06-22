<a href='http://ci.c42.in/projects/goldberg'><img src='http://ci.c42.in/projects/goldberg.png' alt='Goldberg Build Status'></a>

# Goldberg

Goldberg is a lightweight Continuous Integration Server that works for any language. It also supports RVM and Bundler for Ruby Projects.

Visit [ci.c42.in][] to see a live Goldberg server.

### Installation

Please refer to INSTALLATION.md. More configuration options are in CONFIGURATION.md
       
#### Callbacks & Email Notifications

Goldberg provides on_build_completion, on_build_failure, on_build_success & on_build_fixed callbacks, which can be used to extend Goldberg and add functionality that is not provided out of the box. All the callbacks have access to the build that was completed & an object of email notification, which can be used to configure the mails to be sent on these events. The on_build_completion callback has an extra parameter previous_build_status.

The callbacks are part of goldberg_config.rb

     #Goldberg callbacks
    Project.configure do |config|

      config.on_build_completion do |build,notification,previous_build_status|
        # sending mail
        notification.from('from@example.com').to('to@example.com').with_subject("build for #{build.project.name} #{build.status}").send
      end

      config.on_build_success do |build,notification|
        # code to deploy on staging
      end

      config.on_build_failure do |build,notification|
        # post to IRC channel & send mail
      end

      config.on_build_fixed do |build,notification|
        # post to IRC channel & deploy on staging
      end
    end

Assume you want to post a message on IRC channel & there is a gem that can be used to do so, you can simply require the gem at the start of the project_config.rb file & write the code to post message in any of the callbacks.

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

