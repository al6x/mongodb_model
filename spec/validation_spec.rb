require 'spec_helper'

describe "Validations" do
  with_mongo_model

  before :all do
    class BaseUnit
      inherit Mongo::Model
      collection :units

      attr_accessor :name
    end
  end
  after{remove_constants :Unit}
  after(:all){remove_constants :BaseUnit}

  describe 'basics' do
    it "before validation callback" do
      class Unit < BaseUnit
        before_validate :check_name
        def check_name
          errors[:name] = 'invalid name'
        end
      end

      unit = Unit.new
      unit.save.should be_false
    end

    it "should not save model with errors" do
      unit = BaseUnit.build name: 'Zeratul'
      unit.save.should be_true

      unit.errors.clear
      unit.save.should be_true

      unit.errors[:name] = 'hairy error'
      unit.save.should be_false

      unit.errors.clear
      unit.save.should be_true
    end

    it "should check :errors only and ignore valid? method" do
      unit = BaseUnit.build name: 'Zeratul'
      unit.should_not_receive(:valid?)
      unit.save.should be_true
    end
  end

  describe "validatable2" do
    it "smoke test" do
      class Unit < BaseUnit
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
      unit = BaseUnit.new
      unit.should_receive(:validate)
      unit.save
    end

    it "should not save errors as instance variables" do
      unit = BaseUnit.new
      unit.valid?
      unit.instance_variables.select{|iv_name| iv_name !~ /^@_/}.should be_empty
    end
  end

  describe "special" do
    it 'validates_uniqueness_of' do
      class Unit < BaseUnit
        validates_uniqueness_of :name
      end

      unit = Unit.build name: 'Zeratul'
      unit.save.should be_true

      unit = Unit.build name: 'Zeratul'
      unit.save.should be_false
      unit.errors[:name].first.should =~ /unique/
    end

    it 'validates_uniqueness_of with scope' do
      class Unit < BaseUnit
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