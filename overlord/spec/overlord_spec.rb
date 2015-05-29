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
      bomb = Bomb.find(bomb.id)
      expect(bomb.status).to eq("active")
    end

    it "explodes after the detonation_time has passed" do
      bomb = Bomb.last
      Timecop.freeze(Time.parse '2015-01-15 12:34:00') do
        post "/bomb_activate", "bomb_id=#{bomb.id}&activation_code=2345"
        bomb = Bomb.find(bomb.id)
        expect(bomb.status).to eq("active")
      end

      Timecop.freeze(Time.parse '2015-01-15 12:36:00') do
        bomb = Bomb.find(bomb.id)
        expect(bomb.status).to eq("explode")
      end
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
      bomb = Bomb.find(bomb.id)
      expect(bomb.status).to eq("active")
    end

     it "accepts the code for activation if its right and activated the bomb" do
      bomb = Bomb.last
      post "/bomb_deactivate", "bomb_id=#{bomb.id}&deactivation_code=2345"
      bomb = Bomb.find(bomb.id)
      expect(bomb.status).to eq("inactive")
    end
  end

  describe "diffusing a live bomb" do
    before(:each) do
      post "/bomb", "activation_code=1234&deactivation_code=2345"
      bomb = Bomb.last
      post "/bomb_activate", "bomb_id=#{bomb.id}&activation_code=1234"
    end

    it "diffuses bomb when safe wire is cut" do
      bomb = Bomb.last
      post "/bomb_diffuse", "bomb_id=#{bomb.id}&wire_color=green"
       bomb = Bomb.find(bomb.id)
      expect(bomb.status).to eq("inactive")
    end

    it "explodes bomb when unsafe wire is cut" do
      bomb = Bomb.last
      post "/bomb_diffuse", "bomb_id=#{bomb.id}&wire_color=red"
      bomb = Bomb.find(bomb.id)
      expect(bomb.status).to eq("explode")
    end
  end

  describe "retrying failed attempts of deactivating" do
    before(:each) do
      post "/bomb", "activation_code=1234&deactivation_code=2345"
      bomb = Bomb.last
      post "/bomb_activate", "bomb_id=#{bomb.id}&activation_code=1234"
    end
    it "explodes when deactivation_code is wrong 3 times" do
      bomb = Bomb.last
      post "/bomb_deactivate", "bomb_id=#{bomb.id}&deactivation_code=1234"
      bomb = Bomb.find(bomb.id)
      expect(bomb.status).to eq("active")
      post "/bomb_deactivate", "bomb_id=#{bomb.id}&deactivation_code=5678"
      bomb = Bomb.find(bomb.id)
      expect(bomb.status).to eq("active")
      post "/bomb_deactivate", "bomb_id=#{bomb.id}&deactivation_code=9876"
      bomb = Bomb.find(bomb.id)
      expect(bomb.status).to eq("explode")
    end
  end

end
