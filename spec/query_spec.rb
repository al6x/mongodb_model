require 'spec_helper'

describe "Model Query" do
  with_mongo_model

  before :all do
    class Unit
      inherit Mongo::Model
      collection :units

      attr_accessor :name
    end
  end
  after(:all){remove_constants :Unit, :SpecialUnit}

  before{@zeratul = Unit.build name: 'Zeratul'}

  it 'exist?' do
    Unit.should_not exist(name: 'Zeratul')
    @zeratul.save!
    Unit.should exist(name: 'Zeratul')
  end

  it 'first, first!' do
    Unit.first.should be_nil
    -> {Unit.first!}.should raise_error(Mongo::NotFound)
    @zeratul.save
    Unit.first.should_not be_nil
    Unit.first!.should_not be_nil
  end

  it 'all, each' do
    list = []; Unit.each{|o| list << o}
    list.size.should == 0

    @zeratul.save
    list = []; Unit.each{|o| list << o}
    list.size.should == 1
  end

  it 'dynamic finders integration' do
    Unit.first_by_name('Zeratul').should be_nil
    u = Unit.build(name: 'Zeratul')
    u.save!
    Unit.first_by_name('Zeratul').name.should == 'Zeratul'
    Unit.by_id!(u._id).name.should == 'Zeratul'
  end

  it 'build, create, create!' do
    class SpecialUnit < Unit
      attr_accessor :age
    end

    u = SpecialUnit.query(name: 'Zeratul').build age: 500
    [u.name, u.age].should == ['Zeratul', 500]

    SpecialUnit.destroy_all
    SpecialUnit.query(name: 'Zeratul').create age: 500
    u = SpecialUnit.first
    [u.name, u.age].should == ['Zeratul', 500]

    SpecialUnit.destroy_all
    SpecialUnit.query(name: 'Zeratul').create! age: 500
    u = SpecialUnit.first
    [u.name, u.age].should == ['Zeratul', 500]
  end

  it "build should assign protected attributes" do
    class SpecialUnit < Unit
      attr_accessor :age, :status
      assign do
        name String, true
        age  Integer, true
      end
    end

    -> {SpecialUnit.query(name: 'Zeratul').build age: 500, status: 'active'}.should raise_error(/not allowed/)
    u = SpecialUnit.query(name: 'Zeratul', status: 'active').build age: 500
    u.status.should == 'active'
  end
end