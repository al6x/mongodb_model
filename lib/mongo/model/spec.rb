require 'mongo/object/spec'
require 'file_model/spec'

rspec do
  class << self
    def with_mongo_model
      with_mongo
      before{Mongo::Model::IdentityMap.clear}
    end

    def with_models *args
      ::Models
      with_mongo_model *args
    end
  end
end