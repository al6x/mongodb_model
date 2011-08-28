require 'spec_helper'

describe 'Model callbacks' do
  with_mongo

  after(:all){remove_constants :TheModel, :Player}

  it "callback integration" do
    class TheModel
      inherit Mongo::Model
    end

    model = TheModel.new

    model.should_receive(:run_before_callbacks).with(:save, {method: :save})
    model._run_callbacks :before, :save
  end

  it "integration smoke test" do
    class Player
      inherit Mongo::Model

      before_validate :before_validate_check
      after_save :after_save_check

      attr_accessor :missions

      class Mission
        inherit Mongo::Model

        before_validate :before_validate_check
        after_save :after_save_check
      end
    end

    mission = Player::Mission.new
    player = Player.new
    player.missions = [mission]

    player.should_receive(:before_validate_check).once.ordered.and_return(nil)
    mission.should_receive(:before_validate_check).once.ordered.and_return(nil)
    player.should_receive(:after_save_check).once.ordered.and_return(nil)
    mission.should_receive(:after_save_check).once.ordered.and_return(nil)

    db.units.save(player).should be_true
  end
end