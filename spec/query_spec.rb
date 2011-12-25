require 'spec_helper'

describe "Query" do
  with_mongo_model

  before :all do
    class Unit
      inherit Mongo::Model
      collection :units

      attr_accessor :name
    end
  end
  after(:all){remove_constants :Unit, :SpecialUnit}

  before{@unit = Unit.build name: 'Zeratul'}

  it 'should check existence' do
    Unit.should_not exist(name: 'Zeratul')
    @unit.save!
    Unit.should exist(name: 'Zeratul')
  end

  it 'should return first model (also with bang version)' do
    Unit.first.should be_nil
    -> {Unit.first!}.should raise_error(Mongo::NotFound)
    @unit.save
    Unit.first.should_not be_nil
    Unit.first!.should_not be_nil
  end

  it 'should return all and iterate over each models' do
    list = []; Unit.each{|o| list << o}
    list.size.should == 0

    @unit.save
    list = []; Unit.each{|o| list << o}
    list.size.should == 1
  end

  it 'should have dynamic finders' do
    Unit.first_by_name('Zeratul').should be_nil
    u = Unit.build(name: 'Zeratul')
    u.save!
    Unit.first_by_name('Zeratul').name.should == 'Zeratul'
    Unit.by_id!(u.id).name.should == 'Zeratul'
  end

  it 'should be integrated with build, create and create!' do
    class SpecialUnit < Unit
      attr_accessor :age
    end

    u = SpecialUnit.query(name: 'Zeratul').build age: 500
    [u.name, u.age].should == ['Zeratul', 500]

    SpecialUnit.delete_all
    SpecialUnit.query(name: 'Zeratul').create age: 500
    u = SpecialUnit.first
    [u.name, u.age].should == ['Zeratul', 500]

    SpecialUnit.delete_all
    SpecialUnit.query(name: 'Zeratul').create! age: 500
    u = SpecialUnit.first
    [u.name, u.age].should == ['Zeratul', 500]
  end

  it "should not allow to mass-assign protected attributes" do
    class SpecialUnit < Unit
      attr_accessor :age, :status
      assign do
        name String, true
        age  Integer, true
      end
    end

    u = SpecialUnit.query(name: 'Zeratul').build status: 'active'
    u.status.should be_nil

    u = SpecialUnit.query(name: 'Zeratul', status: 'active').build age: 500
    u.status.should == 'active'
  end

  it "should support where clause" do
    query = Unit.where(name: 'Zeratul')
    query = query.where(race: 'Protoss')
    query.should == Mongo::Model::Query.new(Unit, {name: 'Zeratul', race: 'Protoss'}, {})
  end
end