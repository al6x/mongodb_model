require 'spec_helper'

describe 'Collection & Database' do
  with_mongo_model

  before do
    class TheModel
      inherit Mongo::Model
    end
  end
  after{remove_constants :TheModel}

  # Discarded
  # it "global setting" do
  #   Mongo::Model.connection = db.connection
  #   Mongo::Model.db = db
  #
  #   Mongo::Model.connection.should == db.connection
  #   Mongo::Model.db.should == db
  # end

  it "should allow set database per model" do
    TheModel.db :special_db_name

    Mongo.should_receive(:db).with(:special_db_name).and_return(:special_db)
    TheModel.db.should == :special_db
  end

  # Discarded
  # it "should allow set collection per model" do
  #   Mongo::Model.db = db
  #
  #   # TheModel.default_collection_name.should == :the_model
  #   # TheModel.collection.name.should == 'the_model'
  #
  #   TheModel.collection :units
  #   TheModel.collection.name.should == 'units'
  #
  #   TheModel.collection = nil
  #   units = db.units
  #   TheModel.collection units
  #   TheModel.collection.should == units
  #
  #   TheModel.collection = nil
  #   TheModel.collection{units}
  #   TheModel.collection.should == units
  # end
end