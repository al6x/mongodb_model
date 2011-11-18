require 'spec_helper'
require 'mongo/object/spec/shared_object_crud'

describe "Model CRUD" do
  with_mongo_model

  describe 'single model' do
    it_should_behave_like "single object CRUD"

    before do
      class Unit
        inherit Mongo::Model
        collection :units

        attr_accessor :name, :info
        def == o; [self.class, name, info] == [o.class, o.name, o.info] end
      end

      @unit = Unit.build name: 'Zeratul', info: 'Dark Templar'
    end
    after{remove_constants :Unit}

    it 'should perform CRUD' do
      # Read.
      Unit.count.should == 0
      Unit.all.should == []
      Unit.first.should == nil

      # Create.
      @unit.save.should be_true
      @unit._id.should_not be_nil

      # Read.
      Unit.count.should == 1
      Unit.all.should == [@unit]
      Unit.first.should == @unit
      Unit.first.object_id.should_not == @unit.object_id

      # Update.
      @unit.info = 'Killer of Cerebrates'
      @unit.save.should be_true
      Unit.count.should == 1
      Unit.first(name: 'Zeratul').info.should == 'Killer of Cerebrates'

      # Delete.
      @unit.delete.should be_true
      Unit.count.should == 0
    end

    it 'should be able to save model to another collection' do
      # Create.
      @unit.save(collection: db.heroes).should be_true
      @unit._id.should_not be_nil

      # Read.
      Unit.count.should == 0
      db.heroes.count.should == 1
      db.heroes.first.should == @unit
      db.heroes.first.object_id.should_not == @unit.object_id

      # Update.
      @unit.info = 'Killer of Cerebrates'
      @unit.save(collection: db.heroes).should be_true
      Unit.count.should == 0
      db.heroes.count.should == 1
      db.heroes.first(name: 'Zeratul').info.should == 'Killer of Cerebrates'

      # Delete.
      @unit.delete(collection: db.heroes).should be_true
      db.heroes.count.should == 0
    end

    it 'should build model' do
      u = Unit.build name: 'Zeratul'
      u.name.should == 'Zeratul'
    end

    it 'should create model' do
      u = Unit.create(name: 'Zeratul')
      u.new_record?.should be_false

      u = Unit.create!(name: 'Zeratul')
      u.new_record?.should be_false
    end

    it 'should delete all models' do
      Unit.create(name: 'Zeratul')
      Unit.count.should == 1
      Unit.delete_all
      Unit.count.should == 0

      Unit.delete_all!
    end

    it 'should accept modifiers' do
      unit = Unit.create! name: 'Zeratul'

      Unit.update({_id: unit._id}, _set: {name: 'Tassadar'})
      unit.reload
      unit.name.should == 'Tassadar'

      unit.update _set: {name: 'Fenix'}
      unit.reload
      unit.name.should == 'Fenix'
    end
  end

  describe 'embedded model' do
    it_should_behave_like 'embedded object CRUD'

    before do
      class Unit
        inherit Mongo::Model
        collection :units

        attr_accessor :items
        def == o; [self.class, self.items] == [o.class, o.items] end

        class Item
          inherit Mongo::Model

          attr_accessor :name
          def == o; [self.class, self.name] == [o.class, o.name] end
        end
      end

      @item_class = Unit::Item
      @unit = Unit.new
      @unit.items = [
        Unit::Item.build(name: 'Psionic blade'),
        Unit::Item.build(name: 'Plasma shield'),
      ]
    end
    after{remove_constants :Unit}

    it 'should perform CRUD' do
      # Create.
      @unit.save.should be_true
      @unit._id.should_not be_nil

      # Read.
      Unit.count.should == 1
      unit = Unit.first
      unit.should == @unit
      unit.object_id.should_not == @unit.object_id

      # Update.
      @unit.items.first.name = "Psionic blade level 3"
      @unit.items << Unit::Item.build(name: 'Power suit')
      @unit.save.should be_true
      Unit.count.should == 1
      unit = Unit.first
      unit.should == @unit
      unit.object_id.should_not == @unit.object_id

      # Delete.
      @unit.delete.should be_true
      Unit.count.should == 0
    end
  end
end