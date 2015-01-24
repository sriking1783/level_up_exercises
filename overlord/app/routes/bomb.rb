require 'sinatra'
require 'sinatra/contrib'
require 'dm-sqlite-adapter'
require 'json'

require_relative '../helpers/bomb_helpers'
class Overlord < Sinatra::Application
  include BombHelpers

   before /.*/ do
     if request.url.match(/.json$/)
      request.accept.unshift('application/json')
      request.path_info = request.path_info.gsub(/.json$/,'')
     end
   end

  get '/bomb/:bomb_id' do
    @bomb = Bomb.where("id = ?", params[:bomb_id]).first
    BombHelpers.explode_bomb(@bomb)
    if request.accept.length == 1
      haml :bomb
    else
      respond_to do |format|
        format.json { @bomb.to_json }
        format.html { haml :bomb }
      end
    end
  end

  post '/bomb/diffuse' do
    params = {}
    params = JSON.parse(request.body.read)
    @bomb = Bomb.where("id = ?", params["bomb_id"]).first
    wire = Wire.where(color: params["color"]).first

    if wire.diffuse?
      @bomb.inactive!
    else
      @bomb.explode!
    end
    @bomb.save!

    haml :bomb
  end

  post '/bomb' do
    request_json = {}
    if request.body.try("string") != ""
      request_json = JSON.parse(request.body.read)
    end

    bomb = Bomb.create(
      activation_code: request_json["activation_code"],
      deactivation_code: request_json["deactivation_code"],
      detonation_time: request_json["detonation_time"])

    request_json["wires"] ||= [{ color: "red", diffuse: false },
                                { color: "green", diffuse: true }]

    bomb.save!

    request_json["wires"].each do |wire_options|
      wire = bomb.wires.build(wire_options)
      wire.save
    end

    bomb.to_json
  end

  post '/bomb/activate' do
    request.body

    request_json = JSON.parse(request.body.read)
    bomb = Bomb.where("id = ?", request_json["bomb_id"]).first
    if bomb.match_activation_code?(request_json)
      bomb.active!
      bomb.activated_time = Time.now
      bomb.failed_attempts = 0
      bomb.save!
    end
    BombHelpers.explode_bomb(bomb)
    bomb.to_json
  end

  post '/bomb/deactivate' do
    request_json = {}
    request_json = JSON.parse(request.body.read)
    bomb = Bomb.where("id = ?", request_json["bomb_id"]).first
    if bomb.match_deactivation_code?(request_json)
      bomb.inactive!
      bomb.activated_time = nil
      bomb.failed_attempts = 0
      bomb.save!
    else
      bomb.failed_attempts += 1
      bomb.save!
      if bomb.failed_attempts == 3
        bomb.explode!
        bomb.activated_time = nil
        bomb.save!
      end
    end
    BombHelpers.explode_bomb(bomb)
    bomb.to_json
  end
end