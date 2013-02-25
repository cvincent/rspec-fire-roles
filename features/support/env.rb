require "rubygems"
require "bundler"
Bundler.setup

require "aruba/cucumber"

Before do
  load_paths, requires = ["../../lib"], []
  load_paths.push($LOAD_PATH.grep %r|bundler/gems|)
  load_paths << "."

  set_env('RUBYOPT', "-I#{load_paths.join(':')}")
end
