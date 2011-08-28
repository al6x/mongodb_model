require 'mongodb_model'

require 'rspec_ext'
require 'mongodb_model/spec'

#
# Handy spec helpers
#
rspec do
  def db
    mongo.db
  end
end