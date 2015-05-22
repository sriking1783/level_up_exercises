# run `ruby overlord.rb` to run a webserver for this app

require "sinatra"

enable :sessions

class Overlord < Sinatra::Application
  get "/" do
    "Time to build an app around here. Start time: " + start_time
    session[:bombs]
  end

  get "/:bomb_id" do
    bomb = Bomb.find(params[:bomb_id])
  end

  post "/bomb" do
    bomb_parameters = prepare_bomb_params(params)
    bomb = Bomb.new(bomb_id, bomb_parameters)
    session[:bombs][bomb.id] = bomb
  end

  post '/bomb_activate' do
    bomb = Bomb.find(params[:bomb_id])
    bomb.activate(params["activation_code"])
  end

  post "/bomb_deactivate" do
    bomb = Bomb.find(params[:bomb_id])
    bomb.deactivate(params["deactivation_code"])
  end

  post "/:bomb_id/diffuse" do
  end

  # we can shove stuff into the session cookie YAY!
  def start_time
    session[:start_time] ||= (Time.now).to_s
  end

  def prepare_bomb_params(params)
    bomb_parameters = {}
    bomb_parameters[:activate_code] = params["activation_code"] if params["activation_code"]
    bomb_parameters[:deactivate_code] = params["deactivation_code"] if params["deactivation_code"]
    bomb_parameters[:detonate_time] = params["detonation_time"] if params["detonation_time"]
    bomb_parameters
  end

  def bomb_id
    session[:id] ||= 0
    session[:id] += 1
  end

  def set_bombs
    session[:bombs] ||= {}
  end

  def bombs
    session[:bombs]
  end
end
