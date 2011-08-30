require 'mongo/model'

require 'rspec_ext'
require 'mongo/model/spec'

#
# Handy spec helpers
#
rspec do
  def db
    mongo.db
  end
end