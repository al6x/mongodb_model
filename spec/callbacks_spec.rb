require 'spec_helper'

describe 'Model callbacks' do
  with_mongo_model

  after{remove_constants :TheModel, :Player}

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