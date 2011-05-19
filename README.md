# Goldberg 0.9.0

© Copyright 2010–2011 [C42 Engineering][]. All Rights Reserved.
[![Build Status](http://goldberg.c42.in/projects/goldberg.png)](http://goldberg.c42.in/projects/goldberg)

Goldberg is an alternative to [CruiseControl.rb][] that adheres to the same principles of being simple to use and easy to contribute to. It currently meets all common use cases of a lightweight CI server, and we plan to add more over time. A large majority of projects should be able to switch from CC.rb to Goldberg with little or no effort.

Goldberg can be used to continuously integrate codebases built using any language, not just Ruby.

Visit [goldberg.c42.in][] to see a live Goldberg server.

## Setting up your own Goldberg server

### Prerequisites

Git and Ruby (we usually use MRI 1.9.2, but any flavour should work).
RVM if you want to be able to run projects on different rubies.

Your project should have a Gemfile for [Bundler][].

Goldberg is currently tested only on Linux/Mac OS X but should run on JRuby on Windows.

### Installation
     
       # If you're on Ubuntu, you might need:
       sudo apt-get install sqlite3 libsqlite3-dev
     
       git clone git://github.com/c42/goldberg.git
       bundle install
       rake db:migrate
       ./bin/goldberg bootstrap

### Setting up a new repository
     
       ./bin/goldberg add <url> <name> [command] [--branch <branch_name>]

By default it assumes the master branch. If you need anything else you can specify it while adding.

### Starting Goldberg
     
       # Start the CI server and web front-end at port 4242.
       bin/goldberg start [4242]

### Stopping Goldberg
     
       # Stop a running CI server
       bin/goldberg stop

### Tracking build status

Goldberg generates feeds that work with all CruiseControl-compatible monitors like [CCMenu (mac)][], [BuildNotify (linux)][] & CCTray (windows). The feed is located in the root and is named `cc.xml` (for finicky monitors we also have cctray.xml & XmlStatusReport.aspx). eg: [goldberg.c42.in/cc.xml][]

### Configuration

Goldberg will be checking out your code in \~/.goldberg. If you want to override this create an environment variable called GOLDBERG\_PATH.

You can configure the poller by copying the `config/goldberg.yml.sample` to `config/goldberg.yml`.

#### Force build

By default, the poller is configured to poll every 10 seconds. Even if you click on “force build,” it actually just sets a flag in DB for poller to build the project irrespective of the updates. If you want to it to do a build immediately after clicking on “force build”, then change the frequency to 1 second.

PS: Changing the frequency of poller to 1 second will not cause git calls every one second, as the project controls the frequency at which it should be polled as explained below.

#### Project based configuration

Every project in goldberg can have its own custom configuration by means of adding (either on goldberg instance or by checking it in with the codebase) `goldberg_config.rb` at the root of your codebase. As of now only the following configurations can be overridden, but going further this configuration will be used to configure even more.
     
      #Goldberg configuration
      Project.configure do |config|
        config.frequency = 20
        config.ruby = '1.9.2' # Your server needs to have rvm installed for this setting to be considered
        config.environment_variables = {"FOO" => "bar"}
        config.after_build Proc.new { |build, project| `touch ~/Desktop/actually_built`}
        config.timeout = 10.minutes
      end

If you want the project to be checked for updates every 5 seconds, you will need to change the poller frequency to less than 5 seconds using `goldberg.yml` as mentioned above.

### Help
     
      # To get man page style help
      ./bin/goldberg help [command]

## Contributors

-   Srushtivratha Ambekallu ([srushti][])
-   Jasim A Basheer ([jasim][])
-   Saager Mhatre ([dexterous][])
-   Tejas Dinkar ([gja][])
-   Niranjan Parajape ([achamian][])
-   Todd Sedano ([professor][])
-   Drew Olson ([drewolson][])
-   Aakash Dharmadhikari ([aakashd][])

  [C42 Engineering]: http://c42.in
  [CruiseControl.rb]: https://github.com/thoughtworks/cruisecontrol.rb
  [goldberg.c42.in]: http://goldberg.c42.in
  [Bundler]: http://gembundler.com/
  [CCMenu (mac)]: http://ccmenu.sourceforge.net/
  [BuildNotify (linux)]: https://bitbucket.org/Anay/buildnotify/wiki/Home
  [goldberg.c42.in/XmlStatusReport.aspx]: http://goldberg.c42.in/XmlStatusReport.aspx
  [srushti]: http://github.com/srushti
  [jasim]: http://github.com/jasim
  [dexterous]: http://github.com/dexterous
  [gja]: http://github.com/gja
  [achamian]: http://github.com/achamian
  [professor]: http://github.com/professor
  [drewolson]: http://github.com/drewolson
  [aakashd]: http://github.com/aakashd
