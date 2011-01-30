module Cinch
  module Plugins
    module Github
      autoload :Issue, File.expand_path('../github/issue', __FILE__)
    end
  end
end
