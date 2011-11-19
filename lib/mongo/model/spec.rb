require 'mongo/object/spec'
require 'file_model/spec'

rspec do
  class << self
    def with_mongo_model
      with_mongo
      before{Mongo::Model::IdentityMap.clear}
    end
  end
end