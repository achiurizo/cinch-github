require File.expand_path('../teststrap',__FILE__)

context "Issue Plugin" do
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
      mock_match issue, %r{help github issue},        :display_help
      mock_match issue, %r{issue (open|closed) (.*)}, :get_ticket
      mock_match issue, %r{issue (.*)},               :get_ticket
      mock_match issue, %r{issue link (.*)},          :reply_link 
    end
    asserts("that it has matches") { issue.new(Cinch::Bot.new) }
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
    
    context "with state" do 
      setup do
        @issue = issue.new(Cinch::Bot.new)
        @message = mock()
        @issue.expects(:search_issue).with('bob','open').returns([[false,true], true])
        @issue.expects(:output).with(@message, true).returns(true)
      end
      asserts("that it searches") { @issue.get_ticket(@message, 'bob', 'open') }
    end

    context "without state" do 
      setup do
        @issue   = issue.new(Cinch::Bot.new)
        @message = mock()
        @issue.expects(:search_issue).with('bob', nil).returns([[false,true], true])
        @issue.expects(:output).with(@message, true).returns(true)
      end
      asserts("that it searches") { @issue.get_ticket(@message, 'bob') }
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

end
