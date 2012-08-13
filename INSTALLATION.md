       
### Installing Goldberg

1. **Clone and setup the app:**

    ```
    git clone git://github.com/c42/goldberg.git
    cd goldberg
    bundle install
    rake db:setup
    ```

2. **Start the web server:**

  If you are in development mode, simply run:
    `
    rails server
    `
 
  For production deployment, deploy Goldberg as a typical Rails application behind Apache/nginx+Passenger.

3. **Start the poller:**

  If you are in development mode, the poller will start automatically when you run `rails server` in the previous step.

  But for production, you have to run the poller separately as a background daemon. It can be started from the command line as `bin/goldberg start_poller`

  However we recommend that you run the poller using a monitoring tool like Monit or [God](https://github.com/mojombo/god). Goldberg ships with a God script that you can run using `god -c config/god-script.rb`

### Setup the Repository

Once you have the web front-end and poller working, it is time to add your repository.

       RAILS_ENV=production bin/goldberg add <url> <name> [--branch <branch_name>] [--scm <git|svn>]

By default it assumes the <code>master</code> branch. Take a look at CONFIGURATION.md for other configuration options.

### Removing a repository

       bin/goldberg remove <name>

### Prerequisites

* Ruby - CRuby > 1.9.2 and JRuby 1.6.2 and upward are supported
* Git > v1.6.5 and SVN > v1.6.0 (hg and bzr are currently unsupported, but are on the roadmap)
* RVM if you want to be able to run projects on different rubies.
* Your project should have a Gemfile to use [Bundler][].

Goldberg is currently tested only on Linux/Mac OS X but should run on JRuby on Windows.

If you're on Ubuntu, you might need `sudo apt-get install sqlite3 libsqlite3-dev libncursesw5-dev`
       
