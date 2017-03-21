# unt-blacklight: UNT Libraries' Development Blacklight Instance
Version 0.01

## About

I'm investigating implementing a custom [Blacklight](http://projectblacklight.org/) instance to use to replace the old-school online catalog interface we currently use (III's WebPAC Pro). I'm using our [Catalog API](https://github.com/unt-libraries/catalog-api) Solr instance as the backend and have created a branch on that project to manage changes needed there to better support Blacklight.

For now this is mostly a scratch space for implementation notes to myself; as it gets closer to a workable application, I'll clean this up. I'm new to Ruby and Rails, so some of the installation/configuration details might be a little naive.

Obviously this is a work-in-progress.

## Installation

This assumes a *nix environment, bash shell.

**Install the Catalog API.**

[Follow these instructions](https://github.com/unt-libraries/catalog-api) to install the Catalog API.

Once installed, switch over to the `blacklight` branch. That's where all of the changes needed for Blacklight will be happening.

    $ git checkout blacklight

**(Java should already be installed.)** You need Java for Solr, which you'll have already if you followed the Catalog API install instructions.

**Install Ruby.** Current Blacklight wants version 2.2.0 or greater. We'll install using [rbenv](https://github.com/rbenv/rbenv) and [rbenv/ruby-build](https://github.com/rbenv/ruby-build).

1. Install rbenv to `~/.rbenv`:

        $ git clone https://github.com/rbenv/rbenv.git ~/.rbenv

2. To `~/.bash_profile`, add:

        export PATH=$PATH:$HOME/.rbenv/bin
        eval "$(rbenv init -)"
    Note: If using a different shell, double-check to make sure the `rbenv init` command syntax is correct for your shell by running `~/.rbenv/bin/rbenv init` directly.
    
3. Restart your shell to enact `.bash_profile` changes.
4. Install ruby-build as an rbenv plugin:

        $ git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

5. Install the latest Ruby version using rbenv:

        $ rbenv install 2.4.0

6. After it's installed, you can activate this Ruby version globally:

        $ rbenv global 2.4.0
    
    This writes that version name to a `~/.rbenv/version` file. Any shell you open will use that Ruby environment by default. You can also set local Ruby environments and even directory-specific Ruby environments, but for now this will be the easiest to manage.

7. Do a 

        $ ruby --version
    
    to verify installation.

**Install Bundler.**

    $ gem install bundler

**Install Rails.** Blacklight wants Rails 4.2 or 5.x, and recommends Rails 5. This of course should install the latest stable version:

    $ gem install rails

**Install unt-blacklight.**

1. Clone unt-blacklight repository.

    SSH:

        $ git clone git@github.com:jthomale/unt-blacklight.git unt-blacklight
    
    HTTPS:
    
        $ git clone https://github.com/jthomale/unt-blacklight unt-blacklight

2. Install the bundle for the Rails application.

        $ cd unt-blacklight
        $ bundle install

3. Generate secrets and store in `config/secrets.yml`.

        $ cp config/secrets_templ.yml config/secrets.yml
    
    Use
    
        $ rake secret
    
    to generate new secret keys. The `secrets.yml` file is included in `.gitignore`, so it won't be committed to GitHub if you're working with a forked repository. Even so, generally I think best practice is not to keep the production key in `secrets.yml`, but rather to set the `SECRET_KEY_BASE` environment variable.

4. Run database migrations to generate the sqlite database used by Rails.

        $ rake db:migrate
    
    Like the secrets file, the sqlite3 database files are in `.gitignore` and are kept out of the repository.

## Running Blacklight

Now you'll obviously want to run the new Blacklight instance and make sure it works. So, first start up your Catalog API Solr instance, index some bib records if you need to, and then run:

    $ SOLR_URL="http://localhost:8983/solr/bibdata" rails server

Obviously, point SOLR_URL to the location of the `bibdata` core within your Catalog API instance. This assumes you're running it on the same server you're running the rails server, using the default Solr port (8983).

If all goes well, the rails server should start up and should start listening for connections. Visit your new Blacklight instance at http://localhost:3000/ 

**If you aren't running Blacklight locally**&mdash;that is, if you're running Rails on an external development server and you need to be able to access it in your local browser at some web address, then run `rails server` with the `--binding=0.0.0.0` option. By default it's bound to 127.0.0.1, which means it only listens to local requests, and binding to 0.0.0.0 tells it to accept requests from anywhere.

You can also use the `--port` option to specify a port other than 3000, which is the default. So, for example:

    $ SOLR_URL="http://localhost:8983/solr/bibdata" rails server --port=3001 --binding=0.0.0.0

This would enable external connections to your server on port 3001.

Finally, you can set the `SOLR_URL` in an environment variable instead of setting it inline with the call to `rails server` as shown here.






