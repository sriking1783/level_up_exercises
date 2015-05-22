require_relative "spec_helper"
require "timecop"

describe "bomb" do
  let(:valid_bomb)  { "activation_code=12342&deactivation_code=0000&detonation_time=50" }

  it "should use default activation code if not given" do
    post "/bomb"
    bomb = Bomb.last
    expect(bomb.activation_code).to eq("1234")
  end

  it "should not be activated when first booted" do
    post "/bomb"
    bomb = Bomb.last
    expect(bomb.status).to eq("inactive")
  end

  it "should not use default activation code if given" do
    post "/bomb", valid_bomb
    bomb = Bomb.last
    expect(bomb.activation_code).to eq("12342")
  end

  describe "activating the bomb" do
    before(:each) do
      post "/bomb", "activation_code=2345"
    end

    it "rejects the code for activation if its wrong" do
      bomb = Bomb.last
      post "/bomb_activate", "bomb_id=#{bomb.id}&activation_code=1234"
      expect(bomb.status).to eq("inactive")
    end

     it "accepts the code for activation if its right and activated the bomb" do
      bomb = Bomb.last
      post "/bomb_activate", "bomb_id=#{bomb.id}&activation_code=2345"
      expect(bomb.status).to eq("active")
    end
  end

  describe "deactivating the bomb" do
    before(:each) do
      post "/bomb", "deactivation_code=2345"
      bomb = Bomb.last
      post "/bomb_activate", "bomb_id=#{bomb.id}&activation_code=1234"
    end

    it "rejects the code for activation if its wrong" do
      bomb = Bomb.last
      post "/bomb_deactivate", "bomb_id=#{bomb.id}&deactivation_code=1234"
      expect(bomb.status).to eq("active")
    end

     it "accepts the code for activation if its right and activated the bomb" do
      bomb = Bomb.last
      post "/bomb_deactivate", "bomb_id=#{bomb.id}&deactivation_code=2345"
      expect(bomb.status).to eq("inactive")
    end
  end

end
