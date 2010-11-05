require 'rubygems'
require 'riot'
require 'mocha'
require File.expand_path('../../lib/cinch-github',__FILE__)

class Riot::Situation
  include Mocha::API
  
  # Checks to see if plugin has the designated matches
  # asserts_has_match @issue, /help/, :display_help
  def mock_match(plugin, regex, method_name)
    plugin.expects(:match).with(regex, :method => method_name).returns(true)
  end
  
  
end

class Riot::Context
end

class Object
  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure
      eval("$#{stream} = #{stream.upcase}")
    end
    result
  end
end
