require 'spec_helper'

describe 'Model equality' do
  with_mongo_model

  after{remove_constants :Player}

  it "integration smoke test" do
    class Player
      inherit Mongo::Model

      attr_accessor :name, :mission

      class Mission
        inherit Mongo::Model

        attr_accessor :name
      end
    end

    player1 = Player.new name: 'Alex'
    player1.mission = Player::Mission.new name: 'First Strike'

    player2 = Player.new name: 'Alex'
    player2.mission = Player::Mission.new name: 'First Strike'

    player1.should == player2

    player1.mission.name = 'Into the Flames'
    player1.should_not == player2
  end
end