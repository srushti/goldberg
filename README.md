# Goldberg 1.0.0

© Copyright 2010–2011 [C42 Engineering][]. All Rights Reserved. <a href='http://ci.c42.in/projects/goldberg'><img src='http://ci.c42.in/projects/goldberg.png' alt='Goldberg Build Status'></a>

Goldberg is an alternative to [CruiseControl.rb][] that adheres to the same principles of being simple to use and easy to contribute to. It currently meets all common use cases of a lightweight CI server, and we plan to add more over time. A large majority of projects should be able to switch from CC.rb to Goldberg with little or no effort.

The upcoming [1.1 release](https://github.com/c42/goldberg/issues/milestones?_pjax=true&direction=asc&sort=completeness&state=open) of Goldberg will support [pipelines and stages](http://blog.c42.in/pipelines-what-are-they-good-for).

Goldberg can be used to continuously integrate codebases built using any language, not just Ruby.

Visit [ci.c42.in][] to see a live Goldberg server.

## Setting up your own Goldberg server

### Prerequisites

* Ruby - CRuby 1.8.7/1.9.2 and JRuby 1.6.2 and upward are supported
* Git > v1.6.5 and SVN > v1.6.0 (hg and bzr are currently unsupported, but are on the roadmap)
* RVM if you want to be able to run projects on different rubies.
* Your project should have a Gemfile for [Bundler][].

Goldberg is currently tested only on Linux/Mac OS X but should run on JRuby on Windows.

### Installation

       # If you're on Ubuntu, you might need:
       sudo apt-get install sqlite3 libsqlite3-dev libncursesw5-dev

       git clone git://github.com/c42/goldberg.git
       cd goldberg
       bundle install
       rake db:setup

### Setting up a production instance

We suggest that Goldberg should be used behind apache, nginx or any such web server with passenger, unicorn or mongrel. If you don't have a setup that monitors and restarts processes, you should use a process monitoring tool like God or Monit to manage the server processes & restart them if they happen to die.

A sample god script file <code>config/god-script.rb</code> is available with Goldberg. Details for setting up God can be found at [http://god.rubyforge.org/]

### Setting up a new repository

       RAILS_ENV=production bin/goldberg add <url> <name> [--branch <branch_name>] [--scm <git|svn>]

By default it assumes the <code>master</code> branch. If you want to build on any other branch, use the -b --branch flag to specify it. The default command is <code>rake</code>, but you can also use "rake db:migrate && rake spec" if you have a rails project to build.

Please note that by default, Goldberg times-out builds after 10 minutes. If you have a build that takes longer than this, you can increase the timeout period appropriately. Please see the section on Project Configuration for more details.

### Removing the repository

       bin/goldberg remove <name>

### Starting Goldberg

In development mode simply run:

       rails server

This will also start a daemon for building projects.

In production mode, the web server & the build poller runs in different processes. The web server will have to be set up like any other Rails/Rack application. The poller will have to be run using:

       # Start just the polling/building without a front-end
       bin/goldberg start_poller

There's a god-script under config directory which can be used to start a poller as a daemon process monitored by [God](https://github.com/mojombo/god)

### Tracking build status

Goldberg generates feeds that work with all CruiseControl-compatible monitors like [CCMenu (mac)][], [BuildNotify (linux)][] & CCTray (windows). The feed is located in the root and is named `cc.xml` (for finicky monitors we also have cctray.xml & XmlStatusReport.aspx). eg: [cc.xml](http://ci.c42.in/cc.xml)

### Configuration

Goldberg will be checking out your code in ~/.goldberg. If you want to override this create an environment variable called GOLDBERG\_PATH.

You can configure the poller by copying the `config/goldberg.yml.sample` to `config/goldberg.yml`.

#### Force build

By default, the poller is configured to poll every 10 seconds. Even if you click on “force build,” it actually just sets a flag in DB for poller to build the project irrespective of the updates. If you want to it to do a build immediately after clicking on “force build”, then change the frequency to 1 second.
You can also directly make an http POST to '/projects/:project_name/builds' to force a new build.

PS: Changing the frequency of poller to 1 second will not cause git calls every one second, as the project controls the frequency at which it should be polled as explained below.

#### Project based configuration

Every project in Goldberg can have its own custom configuration by checking in a `goldberg_config.rb` file at the root of the codebase or by adding it on the server under `.goldberg/projects/project_name/code`.

      #Goldberg configuration
      Project.configure do |config|
        config.frequency = 20
        config.ruby = '1.9.2'     # Your server needs to have rvm installed for this setting to be considered
        config.environment_variables = {"FOO" => "bar"}
        config.after_build lambda { |build, project| `touch ~/Desktop/actually_built` }
        config.timeout = 10.minutes
        config.nice = 5           # Use this to reduce the scheduling priority (increase niceness) of CPU
                                  # intensive builds that may otherwise leave the Goldberg web application
                                  # unresponsive. Uses the UNIX `nice` command. Defaults to '0'.
                                  # Positive values have lower priority with a max of 19 on OSX and 20 on
                                  # Linux. You can set negative values, but we don't see the point.
        config.command = 'make'   # To be used if you're using anything other than rake
        config.rake_task = 'ci'   # To be used if your CI build runs something other than the default rake.
                                  # Not relevant if you're using config.command.
        config.group = 'c42'      # Running a lot of projects on one server? Use this to logically group them.
      end

If you want the project to be checked for updates every 5 seconds, you will need to change the poller frequency to less than 5 seconds using `goldberg.yml` as mentioned above.

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

#### Build Artefact publishing

Goldberg allows you to publish build artefacts so that it's accessible from the web interface. Goldberg passes an environment variable 'BUILD_ARTEFACTS' ('BUILD_ARTIFACTS' is an alias) which contains a path on the server's filesystem. You need to, as part of your build, copy your artefacts (say, 'log/test.log', 'coverage/' or 'foo.gem') to the directory whose path BUILD_ARTEFACTS will provide. Goldberg will then publish these on the build page. You can copy over individual files or whole directories.

### Help

      # To get man page style help
      ./bin/goldberg help [command]

### Talking to us

-   Twitter: [@GoldbergCI](http://twitter.com/GoldbergCI 'GoldbergCI')
-   IRC: #goldberg

## Contributors

-   Srushtivratha Ambekallu ([srushti][]) [@srshti](http://twitter.com/srshti 'srshti')
-   Jasim A Basheer ([jasim][])
-   Saager Mhatre ([dexterous][])
-   Tejas Dinkar ([gja][])
-   Niranjan Parajape ([achamian][])
-   Todd Sedano ([professor][])
-   Drew Olson ([drewolson][])
-   Aakash Dharmadhikari ([aakashd][])
-   Rohit Arondekar ([rohit][])
-   Arpan Chinta ([arpancj][])
-   Surya Gaddipati ([suryagaddipati])
-   Lawrence Wang ([levity])

  [C42 Engineering]: http://c42.in
  [CruiseControl.rb]: https://github.com/thoughtworks/cruisecontrol.rb
  [ci.c42.in]: http://ci.c42.in
  [Bundler]: http://gembundler.com/
  [CCMenu (mac)]: http://ccmenu.sourceforge.net/
  [BuildNotify (linux)]: https://bitbucket.org/Anay/buildnotify/wiki/Home
  [ci.c42.in/XmlStatusReport.aspx]: http://ci.c42.in/XmlStatusReport.aspx
  [srushti]: http://github.com/srushti
  [jasim]: http://github.com/jasim
  [dexterous]: http://github.com/dexterous
  [gja]: http://github.com/gja
  [achamian]: http://github.com/achamian
  [professor]: http://github.com/professor
  [drewolson]: http://github.com/drewolson
  [aakashd]: http://github.com/aakashd
  [rohit]: http://github.com/rohit
  [arpancj]: http://github.com/arpancj
  [suryagaddipati]: http://github.com/suryagaddipati
  [levity]: http://github.com/levity

