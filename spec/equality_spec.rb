require 'spec_helper'

describe 'Model equality' do
  with_mongo_model

  after{remove_constants :Unit, :Tags}

  it "should check for equality based on model attributes" do
    class Unit
      inherit Mongo::Model

      attr_accessor :name, :items

      class Item
        inherit Mongo::Model

        attr_accessor :name
      end
    end

    unit1 = Unit.new name: 'Zeratul'
    unit1.items = [Unit::Item.new(name: 'Psionic blade')]

    unit2 = Unit.new name: 'Zeratul'
    unit2.items = [Unit::Item.new(name: 'Psionic blade')]

    unit1.should == unit2

    unit1.items.first.name = 'Power suit'
    unit1.should_not == unit2
  end

  it "should correct compare Array/Hash models (from error)" do
    class Tags < Array
      inherit Mongo::Model
    end

    tags = Tags.new.replace ['a', 'b']
    tags.should_not == Tags.new
  end
end