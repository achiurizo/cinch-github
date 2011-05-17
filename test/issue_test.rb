require File.expand_path('../teststrap',__FILE__)

context "Issue Plugin" do
  setup do
    Cinch::Plugins::Github::Issue.stubs(:__register_with_bot).with(any_parameters).returns(true)
  end

  helper :issue do
    Cinch::Plugins::Github::Issue.configure do |c|
      c.user    = 'achiu'
      c.token   = 'my_token'
      c.author  = 'achiu'
      c.repo    = 'cinch-github'
    end
    Cinch::Plugins::Github::Issue
  end

  context "#configure" do
    setup { issue }
    asserts(:user).equals   'achiu'
    asserts(:token).equals  'my_token'
    asserts(:author).equals 'achiu'
    asserts(:repo).equals   'cinch-github'
  end

  context "matches" do
    setup do
      @issue = issue
      mock_match @issue, %r{help github issue},                :display_help
      mock_match @issue, %r{issue state (open|closed) (.*)},   :get_ticket
      mock_match @issue, %r{issue find (.*)},                  :get_ticket
      mock_match @issue, %r{issue link (.*)},                  :reply_link
      mock_match @issue, %r{issue close (\d+) ?(.*)},          :close_issue
      mock_match @issue, %r{issue reopen (\d+) ?(.*)},         :reopen_issue
      mock_match @issue, %r{issue comment (\d+) ?(.*)},        :comment_issue
      mock_match @issue, %r{issue new (.*)},                   :new_issue
    end
    asserts("that it has matches") { @issue.new(Cinch::Bot.new) }
  end


  context "#issue_link" do
    setup { issue.new(Cinch::Bot.new) }
    asserts("that returns the correct issue") do
      topic.issue_link(135)
    end.equals 'https://www.github.com/achiu/cinch-github/issues/135'
  end

  context "#reply_link" do
    setup { @m = mock() }

    context "with number" do
      setup { @m.expects(:reply).with("https://www.github.com/achiu/cinch-github/issues/1").returns(true) }
      asserts("that it returns link") { issue.new(Cinch::Bot.new).reply_link(@m, '1') }
    end

    context "not a number" do
      setup { @m.expects(:reply).with("You need to give me a number...").returns(true) }
      asserts("that it returns a message") { issue.new(Cinch::Bot.new).reply_link(@m,'ab1cx2d') }
    end
  end

  context "#display_help" do
    setup do
      @user    = mock() ; @user.expects(:send).with { |value| value =~ /\!issue/ }.returns(true)
      @replier = mock() ; @replier.expects(:nick).returns("bob")
      @message = mock() ; @message.expects(:user).returns(@replier)
      @issue   = issue.new(Cinch::Bot.new) ; @issue.expects(:User).with("bob").returns(@user)
    end
    asserts("that it displays message") { @issue.display_help(@message) }
  end

  context "#get_ticket" do

    context "with closed state" do
      setup do
        @issue = issue.new(Cinch::Bot.new)
        @message = mock()
        @issue.expects(:search_issue).with('bob','open').returns([[false,true], true])
        @issue.expects(:output).with(@message, true).returns(true)
      end
      asserts("that it searches") { @issue.get_ticket(@message, 'open', 'bob') }
    end

    context "without state" do
      setup do
        @issue   = issue.new(Cinch::Bot.new)
        @message = mock()
        @issue.expects(:search_issue).with('what+bob', nil).returns([[false,true], true])
        @issue.expects(:output).with(@message, true).returns(true)
      end
      asserts("that it searches") { @issue.get_ticket(@message, 'what bob') }
    end

  end

  context "#search_issue" do

    context "with default" do
      setup do
        @issue = issue.new(Cinch::Bot.new)
        @issue.expects(:authenticated_with).with(:login => 'achiu',:token => 'my_token').returns(true)
        params = {:user => 'achiu', :repo => 'cinch-github', :state => 'open', :keyword => 'bob'}
        Octopi::Issue.expects(:search).with(params).returns(true)
      end
      asserts("that it searches with state open") { @issue.search_issue('bob') }
    end

    context "with state" do
      setup do
        @issue = issue.new(Cinch::Bot.new)
        @issue.expects(:authenticated_with).with(:login => 'achiu', :token => 'my_token').returns(true)
        params = { :user => 'achiu', :repo => 'cinch-github', :state => 'closed', :keyword => 'boo' }
        Octopi::Issue.expects(:search).with(params).returns(true)
      end
      asserts("that it searches with state closed") { @issue.search_issue('bob', 'closed') }
    end

  end

  context "#comment_issue" do
    setup do
      @m = mock()
      @m.expects(:reply).returns(true)
      @issue = issue.new(Cinch::Bot.new)
      @issue.expects(:authenticated_with).at_least_once.with(:login => 'achiu', :token => 'my_token').returns(true)
      @mock_issue = mock()
      @mock_issue.expects(:comment).returns(true)
      params = { :user => 'achiu', :repo => 'cinch-github', :number => 3 }
      Octopi::Issue.expects(:find).with(params).returns(@mock_issue)
    end
    asserts("that it finds the ticket and adds a comment") { @issue.comment_issue(@m, 3, "foo bar") }
  end

  context "#close_issue" do
    setup do
      @m = mock()
      @m.expects(:reply).returns(true)
      @issue = issue.new(Cinch::Bot.new)
      @issue.expects(:authenticated_with).at_least_once.with(:login => 'achiu', :token => 'my_token').returns(true)
      @mock_issue = mock()
      @mock_issue.expects(:close!).returns(true)
      params = { :user => 'achiu', :repo => 'cinch-github', :number => 3 }
      Octopi::Issue.expects(:find).with(params).returns(@mock_issue)
    end
    asserts("that it finds the ticket and marks it closed") { @issue.close_issue(@m, 3) }
  end

  context "#reopen_issue" do
    setup do
      @m = mock()
      @m.expects(:reply).returns(true)
      @issue = issue.new(Cinch::Bot.new)
      @issue.expects(:authenticated_with).at_least_once.with(:login => 'achiu', :token => 'my_token').returns(true)
      @mock_issue = mock()
      @mock_issue.expects(:reopen!).returns(true)
      params = { :user => 'achiu', :repo => 'cinch-github', :number => 3 }
      Octopi::Issue.expects(:find).with(params).returns(@mock_issue)
    end
    asserts("that it finds the ticket and marks it re-opened") { @issue.reopen_issue(@m, 3) }
  end

  context "#new_issue" do
    setup do
      @m = mock()
      @m.expects(:reply).returns(true)
      @issue = issue.new(Cinch::Bot.new)
      @issue.expects(:authenticated_with).at_least_once.with(:login => 'achiu', :token => 'my_token').returns(true)
      params = { :user => 'achiu', :repo => 'cinch-github', :number => 3 }
      Octopi::Issue.expects(:open).with(params).returns(@mock_issue)
    end
    asserts("that it opens a new issue") { @issue.new_issue(@m, 'test issue') }
  end

end
