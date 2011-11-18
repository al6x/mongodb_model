require 'spec_helper'

describe "Validations" do
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

    it 'should not save/update/delete invalid objects' do
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

    it 'should not save/update/delete invalid embedded objects' do
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

  describe 'Basics' do
    before do
      class Unit
        inherit Mongo::Model
        collection :units

        attr_accessor :name
      end
    end
    after{remove_constants :Unit}

    it "before validation callback" do
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

  describe "validatable2" do
    before do
      class Unit
        inherit Mongo::Model
        collection :units

        attr_accessor :name
      end
    end
    after{remove_constants :Unit}

    it "smoke test" do
      class Unit
        validates_presence_of :name
      end

      unit = Unit.new
      unit.should_not be_valid
      unit.errors.size.should == 1
      unit.errors.first.first.should == :name
      unit.save.should be_false

      unit.errors.clear
      unit.name = 'Zeratul'
      unit.should be_valid
      unit.errors.should be_empty
      unit.save.should be_true
    end

    it "should validate before save" do
      unit = Unit.new
      unit.should_receive(:run_validations)
      unit.save
    end

    it "should not save errors as instance variables" do
      unit = Unit.new
      unit.valid?
      unit.instance_variables.select{|iv_name| iv_name !~ /^@_/}.should be_empty
    end
  end

  describe "Special validators" do
    before do
      class Unit
        inherit Mongo::Model
        collection :units

        attr_accessor :name
      end
    end
    after{remove_constants :Unit}

    it 'validates_uniqueness_of' do
      class Unit
        validates_uniqueness_of :name
      end

      unit = Unit.build name: 'Zeratul'
      unit.save.should be_true

      unit = Unit.build name: 'Zeratul'
      unit.save.should be_false
      unit.errors[:name].first.should =~ /unique/
    end

    it 'validates_uniqueness_of with scope' do
      class Unit
        attr_accessor :account_id

        validates_uniqueness_of :name, scope: :account_id
      end

      unit = Unit.build name: 'Zeratul', account_id: '10'
      unit.save.should be_true

      unit = Unit.build name: 'Zeratul', account_id: '10'
      unit.save.should be_false

      unit = Unit.build name: 'Zeratul', account_id: '20'
      unit.save.should be_true
    end
  end
end