require 'spec_helper'

describe "Validations" do
  with_mongo_model

  before do
    class Unit
      inherit Mongo::Model
      collection :units

      attr_accessor :errors

      attr_accessor :name
    end
  end
  after{remove_constants :Unit}

  it "should not save model with errors" do
    unit = Unit.build name: 'Zeratul'
    unit.save.should be_true

    unit.errors = []
    unit.save.should be_true

    unit.errors = ['hairy error']
    unit.save.should be_false

    unit.errors = {name: 'hairy error'}
    unit.save.should be_false
  end

  it "should check :errors only and ignore valid? method" do
    unit = Unit.build name: 'Zeratul'
    unit.should_not_receive(:valid?)
    unit.save.should be_true
  end
end