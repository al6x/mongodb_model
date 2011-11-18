require 'spec_helper'

describe "Validation" do
  with_mongo_model

  describe 'CRUD' do
    before do
      class Unit
        inherit Mongo::Model
        collection :units

        attr_accessor :items
        embedded :items

        class Item
          inherit Mongo::Model
        end
      end
    end
    after{remove_constants :Unit}

    before do
      @item = Unit::Item.new
      @unit = Unit.new
      @unit.items = [@item]
    end

    it 'should not save, update or delete invalid objects' do
      # create
      @unit.stub!(:valid?).and_return(false)
      db.units.save(@unit).should be_false

      @unit.stub!(:valid?).and_return(true)
      db.units.save(@unit).should be_true

      # update
      @unit.stub!(:valid?).and_return(false)
      db.units.save(@unit).should be_false

      @unit.stub!(:valid?).and_return(true)
      db.units.save(@unit).should be_true

      # delete
      @unit.stub!(:valid?).and_return(false)
      db.units.delete(@unit).should be_false

      @unit.stub!(:valid?).and_return(true)
      db.units.delete(@unit).should be_true
    end

    it 'should not save, update or delete invalid embedded objects' do
      # create
      @item.stub!(:valid?).and_return(false)
      db.units.save(@unit).should be_false

      @item.stub!(:valid?).and_return(true)
      db.units.save(@unit).should be_true

      # update
      @item.stub!(:valid?).and_return(false)
      db.units.save(@unit).should be_false

      @item.stub!(:valid?).and_return(true)
      db.units.save(@unit).should be_true

      # delete
      @item.stub!(:valid?).and_return(false)
      db.units.delete(@unit).should be_false

      @item.stub!(:valid?).and_return(true)
      db.units.delete(@unit).should be_true
    end

    it "should be able to skip validation" do
      @unit.stub!(:valid?).and_return(false)
      db.units.save(@unit, validate: false).should be_true

      @unit.stub!(:valid?).and_return(true)
      @item.stub!(:valid?).and_return(false)
      db.units.save(@unit, validate: false).should be_true
    end
  end

  describe "basics" do
    before do
      class Unit
        inherit Mongo::Model
        collection :units

        attr_accessor :name
      end
    end
    after{remove_constants :Unit}

    it "should provide validation callback" do
      class Unit
        before_validate :check_name
        def check_name
          errors.add :name, 'invalid name'
        end
      end

      unit = Unit.new
      unit.save.should be_false
    end

    it "should not save model with errors" do
      unit = Unit.build name: 'Zeratul'
      unit.save.should be_true

      unit.errors.clear
      unit.save.should be_true

      unit.errors.stub(:empty?).and_return(false)
      unit.save.should be_false

      unit.errors.stub(:empty?).and_return(true)
      unit.save.should be_true
    end

    it "should add custom validations" do
      class Unit
        validate :check_name
        def check_name
          errors.add :name, 'invalid name'
        end
      end

      unit = Unit.new
      unit.save.should be_false
      unit.errors[:name].should == ['invalid name']
    end

    it "should clear errors before validation" do
      class Unit
        validates_presence_of :name
      end

      unit = Unit.new
      unit.should_not be_valid
      unit.name = 'Zeratul'
      unit.should be_valid
    end
  end
end