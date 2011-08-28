require 'spec_helper'
require 'validatable'

describe "Integration with validatable2" do
  with_mongo_model

  before do
    class Unit
      inherit Mongo::Model
      collection :units

      include Validatable

      attr_accessor :name, :status

      validates_presence_of :name
    end
  end

  after{remove_constants :Unit}

  it "ActiveModel integration smoke test" do
    unit = Unit.new
    unit.should_not be_valid
    unit.errors.size.should == 1
    unit.errors.first.first.should == :name
    unit.save.should be_false

    unit.name = 'Zeratul'
    unit.should be_valid
    unit.errors.should be_empty
    unit.save.should be_true
  end
  
  it "should not save errors as instance variables" do
    unit = Unit.new
    unit.valid?
    unit.instance_variables.select{|iv_name| iv_name !~ /^@_/}.should be_empty
  end
end