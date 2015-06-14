# run `ruby overlord.rb` to run a webserver for this app

require "sinatra"
require 'sinatra/contrib'
require_relative 'bomb'
enable :sessions

class Overlord < Sinatra::Application
  get "/" do
    "Time to build an app around here. Start time: " + start_time
    require 'pry'
    binding.pry
    @bombs = Bomb.all
    p @bombs
    haml :bomb
  end

  get "/bomb" do
    @bomb = Bomb.find(params[:bomb_id])
    haml :bomb
  end

  post "/bomb" do
    last_bomb_id = ( Bomb.last && Bomb.last.id ) || 0
    puts last_bomb_id.to_s
    bomb_parameters = prepare_bomb_params(params)
    @bomb = Bomb.new(last_bomb_id + 1, bomb_parameters)
    session[:bombs] ||= {}
    session[:bombs][@bomb.id] = @bomb
    respond_to do |format|
      format.json { @bomb.to_json }
      format.html { haml :bomb }
    end
  end

  get '/bomb_activate' do
  end

  post '/bomb_activate' do
    bomb = Bomb.find(params[:bomb_id])
    bomb.activate(params["activation_code"])
  end

  post "/bomb_deactivate" do
    bomb = Bomb.find(params[:bomb_id])

    bomb.deactivate(params["deactivation_code"])
  end

  post "/bomb_diffuse" do
    bomb = Bomb.find(params[:bomb_id])
    wire_color = params["wire_color"].to_sym
    bomb.diffuse(wire_color)
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
