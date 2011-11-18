require 'spec_helper'

describe "Integration with Validatable" do
  with_mongo_model

  describe "basics" do
    before do
      class Unit
        inherit Mongo::Model
        collection :units

        attr_accessor :name
      end
    end
    after{remove_constants :Unit}

    it "should perform basic validation" do
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

    it 'should validate uniqueness' do
      class Unit
        validates_uniqueness_of :name
      end

      unit = Unit.build name: 'Zeratul'
      unit.save.should be_true

      unit = Unit.build name: 'Zeratul'
      unit.save.should be_false
      unit.errors[:name].first.should =~ /unique/
    end

    it 'should validate uniqueness within scope' do
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