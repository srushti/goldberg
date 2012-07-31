### Project Checkout path

Goldberg will be checking out your code in ~/.goldberg. If you want to override this create an environment variable called GOLDBERG\_PATH.

#### Project based configuration

Every project in Goldberg can have its own custom configuration by checking in a `goldberg_config.rb` file at the root of the codebase or by adding it on the server under `.goldberg/projects/project_name/code`.

      #Goldberg configuration
      Project.configure do |config|
        config.frequency = 20
        config.ruby = '1.9.2'                                     # Your server needs to have rvm installed for this setting to be considered
        config.environment_variables = {"FOO" => "bar"}
        config.timeout = 10.minutes                               # Defaults to 10.minutes if not configured. Set it to Project::Configuration::NO_TIMEOUT if you don't want it to ever timeout
        config.nice = 5                                           # Use this to reduce the scheduling priority (increase niceness) of CPU
                                                                  # intensive builds that may otherwise leave the Goldberg web application
                                                                  # unresponsive. Uses the UNIX `nice` command. Defaults to '0'.
                                                                  # Positive values have lower priority with a max of 19 on OSX and 20 on
                                                                  # Linux. You can set negative values, but we don't see the point.
        config.command = 'make'                                   # To be used if you're using anything other than rake
        config.rake_task = 'ci'                                   # To be used if your CI build runs something other than the default rake.
                                                                  # Not relevant if you're using config.command.
        config.group = 'c42'                                      # Running a lot of projects on one server? Use this to logically group them.
        config.use_bundle_exec = true                             # Run 'bundle exec rake', recommended for Rails projects
        config.bundle_options = '--without deployment mac'        # Command-line options for bundle install
      end

If you want the project to be checked for updates every 5 seconds, you will need to change the poller frequency to less than 5 seconds by copying `config/goldberg.yml.sample` to `goldberg.yml` and change the poller frequency in the file.

#### Build Artefact publishing

Goldberg allows you to publish build artefacts so that it's accessible from the web interface. Goldberg passes an environment variable 'BUILD_ARTEFACTS' ('BUILD_ARTIFACTS' is an alias) which contains a path on the server's filesystem. You need to, as part of your build, copy your artefacts (say, 'log/test.log', 'coverage/' or 'foo.gem') to the directory whose path BUILD_ARTEFACTS will provide. Goldberg will then publish these on the build page. You can copy over individual files or whole directories.

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

