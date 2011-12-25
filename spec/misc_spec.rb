require 'spec_helper'

describe 'Miscellaneous' do
  with_mongo_model

  before do
    class User
      inherit Mongo::Model
      collection :users

      attr_accessor :name
    end
  end
  after{remove_constants :Unit, :User}

  it "should create timestamps" do
    class Unit
      inherit Mongo::Model
      collection :units

      attr_accessor :name

      timestamps!
    end

    unit = Unit.build name: 'Zeratul'
    unit.save!

    unit = Unit.first
    unit.created_at.should_not be_nil
    unit.updated_at.should_not be_nil
    created_at,updated_at = unit.created_at, unit.updated_at

    unit.save!
    unit.created_at.should == created_at
    unit.updated_at.should >  updated_at
  end

  it 'should have cache' do
    class Unit
      inherit Mongo::Model
    end
    u = Unit.new
    u._cache.should == {}
  end

  it "should convert model to param" do
    u = User.new
    u.to_param.should be_nil
    u.save!
    u.to_param.should_not be_empty
  end

  it "should have dom_id" do
    u = User.new
    u.dom_id.should be_nil
    u.save!
    u.dom_id.should_not be_empty
  end

  it 'should reload model' do
    u = User.create! name: 'Zeratul'
    u.name = 'Jim'
    u.reload
    u.name.should == 'Zeratul'
  end

  describe 'original' do
    before do
      class Unit
        inherit Mongo::Model
        collection :units

        attr_accessor :name
      end

      @unit = Unit.new.tap{|u| u.name = "Zeratul"}
    end
    after{remove_constants :Unit}

    it "should query original from database" do
      @unit.original.should be_nil
      @unit.save!

      unit = Unit.first
      unit.name = "Tassadar"

      Unit.should_receive(:first).with(_id: unit.id).and_return{db.units.first(id: unit.id)}
      unit.original.name.should == "Zeratul"
    end

    it "should use identity map if provided" do
      Unit.inherit Mongo::Model::IdentityMap

      @unit.original.should be_nil
      @unit.save!

      Unit.identity_map.size.should == 0
      unit = Unit.first
      Unit.identity_map.size.should == 1

      unit.name = "Tassadar"

      Unit.should_not_receive :first
      unit.original.name.should == "Zeratul"
    end
  end
end