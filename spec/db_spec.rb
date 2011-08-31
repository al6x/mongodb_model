require 'spec_helper'

describe 'Collection & Database' do
  with_mongo_model

  before :all do
    class TheModel
      inherit Mongo::Model
    end
  end
  after(:all){remove_constants :TheModel}

  after do
    TheModel.db = nil
    TheModel.collection = nil
    Mongo::Model.connection, Mongo::Model.db = nil, nil
  end

  it "global setting" do
    Mongo::Model.connection = db.connection
    Mongo::Model.db = db

    Mongo::Model.connection.should == db.connection
    Mongo::Model.db.should == db
  end

  it "should allow set database per model" do
    Mongo::Model.connection = db.connection
    Mongo::Model.db = db

    TheModel.db.should == db

    TheModel.db :test
    TheModel.db.name.should == 'test'

    TheModel.db = nil
    TheModel.db db
    TheModel.db.should == db

    TheModel.db = nil
    TheModel.db{db}
    TheModel.db.should == db
  end

  it "should allow set collection per model" do
    Mongo::Model.db = db

    # TheModel.default_collection_name.should == :the_model
    # TheModel.collection.name.should == 'the_model'

    TheModel.collection :units
    TheModel.collection.name.should == 'units'

    TheModel.collection = nil
    units = db.units
    TheModel.collection units
    TheModel.collection.should == units

    TheModel.collection = nil
    TheModel.collection{units}
    TheModel.collection.should == units
  end
end