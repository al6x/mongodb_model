require 'mongo/model'

require 'rspec_ext'
require 'mongo/model/spec'

# Shortcuts.
rspec do
  def db
    mongo.db
  end
end

# Helper to simplify callback expectations.
module RSpec::CallbackHelper
  def run_before_callbacks name, method, options = {}
    $_dont_watch_callbacks ? true : send(:"before_#{name}")
  end

  def run_after_callbacks name, method, options = {}
    $_dont_watch_callbacks ? true : send(:"after_#{name}")
  end

  def dont_watch_callbacks &block
    $_dont_watch_callbacks = true
    block.call
  ensure
    $_dont_watch_callbacks = false
  end
end