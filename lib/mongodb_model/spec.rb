require 'mongodb/object/spec'

rspec do
  class << self
    def with_mongo_model
      with_mongo

      before{Mongo::Model.db = mongo.db}
      after{Mongo::Model.db = nil}
    end
  end
end