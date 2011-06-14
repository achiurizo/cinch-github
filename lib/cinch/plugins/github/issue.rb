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

        match "help github issue",                :method => :display_help  # !issue help github issue
        match %r{issue state (open|closed) (.+)},   :method => :get_ticket    # !issue state closed bugs
        match %r{issue find (.+)},                  :method => :get_ticket    # !issue find sinatra
        match %r{issue link (.+)},                  :method => :reply_link    # !issue link 35
        match %r{issue comment (\d+) (.+)},         :method => :comment_issue # !issue comment 35 some comment to add
        match %r{issue close (\d+) ?(.*)},          :method => :close_issue   # !issue close 35 [optional comment]
        match %r{issue reopen (\d+) ?(.*)},         :method => :reopen_issue  # !issue reopen 35 [optional comment]
        match %r{issue new (.+)},                   :method => :new_issue     # !issue new title
        match %r{issue show (\d+)},                 :method => :show_issue    # !issue show 35

        # Display Github Issue Help
        def display_help(m)
          User(m.user.nick).send (<<-EOF).gsub(/^ {10}/,'')
          !issue state [open|closed] [query] - query for a ticket with state closed
          !issue find [query] - query for a ticket with state open
          !issue show [number] - shows detail for issue
          !issue link [number] - returns link for issue number.
          !issue close [number] [optional comment] - close an issue
          !issue reopen [number] [optional comment] - reopen an issue
          !issue comment [number] [comment] - comment on an issue
          !issue comment [new] [title] - create a new issue
          EOF
        end

        # Find ticket with gieven
        def get_ticket(m, *args)
          query, state = args.reverse
          results = search_issue CGI.escape(query), state
          output m, results.first.last
        end
        
        # show ticket title
        def show_issue(m, arg)
          result = find_issue(arg)
          p result
          if result
            m.reply "##{arg} #{result.title} : #{issue_link(arg)}"
          else
            m.reply "Not found"
          end
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

        def find_issue(number)
          authenticated_with :login => self.class.user, :token => self.class.token do
            Octopi::Issue.find :user => self.class.author, :repo => self.class.repo, :number => number
          end
        end

        # Creates an issue
        def new_issue(m, title)
          authenticated_with :login => self.class.user, :token => self.class.token do
            params = { :title => title, :body => "Opened via #{m.user.nick} on IRC" }
            i = Octopi::Issue.open :user => self.class.author, :repo => self.class.repo, :params => params
            if i
              m.reply "Issue created: #{issue_link(i.number)}"
            else
              m.reply "Issue creation failed. Sorry."
            end
          end
        end

        # Comments on the issue
        def comment_issue(m, number, comment)
          i = find_issue(number)
          authenticated_with :login => self.class.user, :token => self.class.token do
            if i.comment "Via #{m.user.nick} on IRC: #{comment}"
              m.reply "Comment added. #{issue_link(number)}"
            end
          end
        end

        # Closes issue
        def close_issue(m, number, comment="")
          i = find_issue(number)
          authenticated_with :login => self.class.user, :token => self.class.token do
            
            if i.close!
              
              msg = "Closed via IRC by #{m.user.nick}"
              if comment != ""
                msg += "\n#{comment}"
              end
              i.comment msg
              m.reply("Marked as closed: #{issue_link(number)}")
            else
              m.reply("Sorry, close failed #{issue_link(number)}")
            end
          end
        end

        # Closes the issue
        def reopen_issue(m, number, comment="")
          i = find_issue(number)
          authenticated_with :login => self.class.user, :token => self.class.token do
            
            if i.reopen!
              
              msg = "Reopened via IRC by #{m.user.nick}"
              if comment != ""
                msg += "\n#{comment}"
              end
              i.comment msg
              m.reply("Marked as reopened: #{issue_link(number)}")
            else
              m.reply("Sorry, reopen failed #{issue_link(number)}")
            end
          end
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
