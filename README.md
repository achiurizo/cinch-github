Cinch-Github
===========

The Cinch Github Plugin. Give your cinch bot abilities to interact with Github! This is still in its early phases!

Installation
---------------------

if you haven't already...

    $ gem install cinch
    
then install this gem.

    $ gem install cinch-github

Cinch::Plugins::Github
----------

### Issues ###

This plugin manages interaction between Github issues via the Github API.

#### Configuration ####

To setup the Issue plugin to work with your cinch bot, we'll need to provide some info like so:

    Cinch::Plugins::Github::Issue.configure do |c|
      c.user    = 'achiu'                   # your github username
      c.token   = 'some_token'              # your github API token
      c.author  = 'padrino'                 # your repository author
      c.repo    = 'padrino-framework'       # your repository name
    end

#### Commands ####

  * !issue state [open|closed] [query]        - returns issues that have state open or closed matching the query
  * !issue find [query]                       - returns issues matching the query. defaults to state open
  * !issue link [number]                      - returns issue link for issue number(must be digits)
  * !issue comment [number] [comment]         - comment on an issue
  * !issue new [title]                        - Create a new issue
  * !issue close [number] [optional comment]  - Close an issue with an optional comment
  * !issue reopen [number] [optional comment] - Reopen an issue with an optional comment
  * !help github issue                        - returns commands for Github Issue

## Integration with Cinch ##

It's simple. follow the guide on cinch or do something like:

    # mybot.rb
    require 'cinch'
    require 'cinch/plugins/github'

    Cinch::Plugins::Github::Issue.configure do |c|
      c.user    = 'achiu'                   # your github username
      c.token   = 'some_token'              # your github API token
      c.author  = 'padrino'                 # your repository author
      c.repo    = 'padrino-framework'       # your repository name
    end

    bot = Cinch::Bot.new do
      configure do |c|
        c.server           = "irc.freenode.net"
        c.nick             = "cinch"
        c.channels         = ["#padrino"]
        c.plugins.plugins  = [Cinch::Plugins::Github::Issue]
      end

    end

    bot.start

Finally, run your bot.

    ruby -rubygems mybot.rb

And there you go!


CONTRIBUTORS
------------

Michael D. Ivey ([ivey](https://github.com/ivey))

  * For having issue return a title and link when called.
  * For adding new, close, reopen, and commenting operations with issues

TODO
-----

  * finish the other plugins for rest of Github API
