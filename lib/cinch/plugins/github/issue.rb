require 'octopi'
require 'cinch'

module Cinch
  module Plugins
    module Github
      # Handles interaction with Issues API.
      class Issue
        include Cinch::Plugin
        include Octopi

        class << self
          attr_accessor :user, :token, :author, :repo

          def configure(&block)
            yield self
          end
        end

        match %r{help github issue},                :method => :display_help  # !issue help gitub issue
        match %r{issue state (open|closed) (.+)},   :method => :get_ticket    # !issue state closed bugs
        match %r{issue find (.+)},                  :method => :get_ticket    # !issue find sinatra
        match %r{issue link (.+)},                  :method => :reply_link    # !issue link 35

        # Display Github Issue Help
        def display_help(m)
          User(m.user.nick).send (<<-EOF).gsub(/^ {10}/,'')
          !issue state [open|closed] [query] - query for a ticket with state closed
          !issue find [query] - query for a ticket with state open
          !issue link [number] - returns link for issue number.
          EOF
        end

        # Find ticket with gieven
        def get_ticket(m, *args)
          query, state = args.reverse
          results = search_issue CGI.escape(query), state
          output m, results.first.last
        end

        # Return the link of the issue
        def reply_link(m, arg)
          arg =~ /\D+/ ? m.reply("You need to give me a number...") : m.reply(issue_link(arg))
        end

        # Use Github API and Search for the Issue
        def search_issue(query, state = 'open')
          authenticated_with :login => self.class.user, :token => self.class.token do
            Octopi::Issue.search :user => self.class.author, :repo => self.class.repo, :state => state, :keyword => query
          end
        end

        # Returns the issue as a link
        def issue_link(number)
          "https://www.github.com/#{self.class.author}/#{self.class.repo}/issues/#{number}"
        end

        private

          # Outputs the reply back to screen
          def output(m, results)
            m.reply "#{results.size} Results"
            results.each { |result| m.reply "#{result['title']} : #{issue_link(result['number'])}" }
          end

      end
    end
  end
end
