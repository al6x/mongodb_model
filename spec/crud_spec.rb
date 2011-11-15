require 'spec_helper'
require 'mongo/object/spec/crud_shared'

describe "Model CRUD" do
  with_mongo_model

  describe 'simple' do
    before :all do
      class Unit
        inherit Mongo::Model
        collection :units

        attr_accessor :name, :info
        def == o; [self.class, name, info] == [o.class, o.respond_to(:name), o.respond_to(:info)] end
      end
    end
    after(:all){remove_constants :Unit}

    before do
      @zeratul = Unit.build name: 'Zeratul', info: 'Dark Templar'
    end

    it_should_behave_like "object CRUD"

    it 'model crud' do
      # read
      Unit.count.should == 0
      Unit.all.should == []
      Unit.first.should == nil

      # create
      @zeratul.save.should be_true
      @zeratul._id.should_not be_nil

      # read
      Unit.count.should == 1
      Unit.all.should == [@zeratul]
      Unit.first.should == @zeratul
      Unit.first.object_id.should_not == @zeratul.object_id

      # update
      @zeratul.info = 'Killer of Cerebrates'
      @zeratul.save.should be_true
      Unit.count.should == 1
      Unit.first(name: 'Zeratul').info.should == 'Killer of Cerebrates'

      # delete
      @zeratul.delete.should be_true
      Unit.count.should == 0
    end

    it 'should be able to save to another collection' do
      # create
      @zeratul.save(collection: db.heroes).should be_true
      @zeratul._id.should_not be_nil

      # read
      Unit.count.should == 0
      db.heroes.count.should == 1
      db.heroes.first.should == @zeratul
      db.heroes.first.object_id.should_not == @zeratul.object_id

      # update
      @zeratul.info = 'Killer of Cerebrates'
      @zeratul.save(collection: db.heroes).should be_true
      Unit.count.should == 0
      db.heroes.count.should == 1
      db.heroes.first(name: 'Zeratul').info.should == 'Killer of Cerebrates'

      # delete
      @zeratul.delete(collection: db.heroes).should be_true
      db.heroes.count.should == 0
    end

    it 'build' do
      u = Unit.build name: 'Zeratul'
      u.name.should == 'Zeratul'
    end

    it 'create' do
      u = Unit.create(name: 'Zeratul')
      u.new_record?.should be_false

      u = Unit.create!(name: 'Zeratul')
      u.new_record?.should be_false
    end

    it 'delete_all' do
      Unit.create(name: 'Zeratul')
      Unit.count.should == 1
      Unit.delete_all
      Unit.count.should == 0

      Unit.delete_all!
    end

    it 'modifiers' do
      unit = Unit.create! name: 'Zeratul'

      Unit.update({_id: unit._id}, _set: {name: 'Tassadar'})
      unit.reload
      unit.name.should == 'Tassadar'

      unit.update _set: {name: 'Fenix'}
      unit.reload
      unit.name.should == 'Fenix'
    end
  end

  describe 'embedded' do
    before :all do
      class Player
        inherit Mongo::Model
        collection :players

        attr_accessor :missions
        def == o; [self.class, self.missions] == [o.class, o.respond_to(:missions)] end

        class Mission
          inherit Mongo::Model

          attr_accessor :name, :stats
          def == o; [self.class, self.name, self.stats] == [o.class, o.respond_to(:name), o.respond_to(:stats)] end
        end
      end
    end
    after(:all){remove_constants :Player}

    before do
      @mission_class = Player::Mission
      @player = Player.new
      @player.missions = [
        Player::Mission.build(name: 'Wasteland',         stats: {'buildings' => 5, 'units' => 10}),
        Player::Mission.build(name: 'Backwater Station', stats: {'buildings' => 8, 'units' => 25}),
      ]
    end

    it_should_behave_like 'embedded object CRUD'

    it 'crud' do
      # create
      @player.save.should be_true
      @player._id.should_not be_nil

      # read
      Player.count.should == 1
      Player.first.should == @player
      Player.first.object_id.should_not == @players.object_id

      # update
      @player.missions.first.stats['units'] = 9
      @player.missions << Player::Mission.build(name: 'Desperate Alliance', stats: {'buildings' => 11, 'units' => 40})
      @player.save.should be_true
      Player.count.should == 1
      Player.first.should == @player
      Player.first.object_id.should_not == @player.object_id

      # delete
      @player.delete.should be_true
      Player.count.should == 0
    end
  end
end