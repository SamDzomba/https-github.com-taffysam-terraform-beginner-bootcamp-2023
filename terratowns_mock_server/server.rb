require 'sinatra'
require 'json'
require 'pry'
require 'active_model'
# We will emaulate mock for having a state or database for this dev server
# by setting a global variable. You shoule never use a gloabl variable
# in Production

$home = {}
# This is a Ruby calss that includes validations from ActiveRecord
# This woill represent our Home resources as a ruby object

class Home

  # ActiveModel is part of Ruby on Rails
  # Is is used as an ORM. Its a module within
  # ActiveModel that provides validations.
  # Very similar and in most cases identical validation
  # https://guides.rubyonrails.org/active_record_basics.html 
  # https://guides.rubyonrails.org/active_record_validations.html 
 
  include ActiveModel::Validations

  # create some virtual atributes to be stored on this object 
  # This will set a getter and a setter
  # eg home =new Home()
  # home.town()
  attr_accessor :town, :name, :description, :domain_name, :content_version

  validates :town, presence: true, inclusion: { in: [
  'melomaniac-mansion'  
  'Cooker Cove'
  'Video Valley' 
  'The Nomad Pad'
  'Gamer Grotto'
  ] } 
 
# Should be visible to all users 
  validates :name, presence: true
# Should be visible to all users  
  validates :description, presence: true
 # we want to lock this down to be only from the cloudfront 
  validates :domain_name, 
    format: { with: /\.cloudfront\.net\z/, message: "domain must be from .cloudfront.net" }
    # uniqueness: true, 

  validates :content_version, numericality: { only_integer: true }
end

# We are extending a class from Sinatra::Base 
# turn this generic class 
class TerraTownsMockServer < Sinatra::Base

  def error code, message
    halt code, {'Content-Type' => 'application/json'}, {err: message}.to_json
  end

  def error_json json
    halt code, {'Content-Type' => 'application/json'}, json
  end

  def ensure_correct_headings
    unless request.env["CONTENT_TYPE"] == "application/json"
      error 415, "expected Content_type header to be application/json"
    end

    unless request.env["HTTP_ACCEPT"] == "application/json"
      error 406, "expected Accept header to be application/json"
    end
  end

  def x_access_code
    '9b49b3fb-b8e9-483c-b703-97ba88eef8e0'
  end

  def x_user_uuid
    'e328f4ab-b99f-421c-84c9-4ccea042c7d1'
  end
# https://swagger.io/docs/specification/authentication/bearer-authentication/
  def find_user_by_bearer_token
    auth_header = request.env["HTTP_AUTHORIZATION"]

 # Check if the bearer token is there   
    if auth_header.nil? || !auth_header.start_with?("Bearer ")
      error 401, "a1000 Failed to authenicate, bearer token invalid and/or teacherseat_user_uuid invalid"
    end
 # Check if the header is there   
    code = auth_header.split("Bearer ")[1]
    if code != x_access_code
      error 401, "a1001 Failed to authenicate, bearer token invalid and/or teacherseat_user_uuid invalid"
    end

    if params['user_uuid'].nil?
      error 401, "a1002 Failed to authenicate, bearer token invalid and/or teacherseat_user_uuid invalid"
    end
 # Does teh token macth the one provided   
    unless code == x_access_code && params['user_uuid'] == x_user_uuid
      error 401, "a1003 Failed to authenicate, bearer token invalid and/or teacherseat_user_uuid invalid"
    end
  end

  # CREATE
  post '/api/u/:user_uuid/homes' do
    ensure_correct_headings
    find_user_by_bearer_token
    puts "# create - POST /api/homes"

    begin
      payload = JSON.parse(request.body.read)
    rescue JSON::ParserError
      halt 422, "Malformed JSON"
    end

    # Validate payload data
    name = payload["name"]
    description = payload["description"]
    domain_name = payload["domain_name"]
    content_version = payload["content_version"]
    town = payload["town"]

    puts "name #{name}"
    puts "description #{description}"
    puts "domain_name #{domain_name}"
    puts "content_version #{content_version}"
    puts "town #{town}"

    home = Home.new
    home.town = town
    home.name = name
    home.description = description
    home.domain_name = domain_name
    home.content_version = content_version
    
    unless home.valid?
      error 422, home.errors.messages.to_json
    end

    uuid = SecureRandom.uuid
    puts "uuid #{uuid}"
    $home = {
      uuid: uuid,
      name: name,
      town: town,
      description: description,
      domain_name: domain_name,
      content_version: content_version
    }

    return { uuid: uuid }.to_json
  end

  # READ
  get '/api/u/:user_uuid/homes/:uuid' do
    ensure_correct_headings
    find_user_by_bearer_token
    puts "# read - GET /api/homes/:uuid"

    # checks for house limit

    content_type :json
    if params[:uuid] == $home[:uuid]
      return $home.to_json
    else
      error 404, "failed to find home with provided uuid and bearer token"
    end
  end

  # UPDATE
  put '/api/u/:user_uuid/homes/:uuid' do
    ensure_correct_headings
    find_user_by_bearer_token
    puts "# update - PUT /api/homes/:uuid"
    begin
      # Parse JSON payload from the request body
      payload = JSON.parse(request.body.read)
    rescue JSON::ParserError
      halt 422, "Malformed JSON"
    end

    # Validate payload data
    name = payload["name"]
    description = payload["description"]
    domain_name = payload["domain_name"]
    content_version = payload["content_version"]

    unless params[:uuid] == $home[:uuid]
      error 404, "failed to find home with provided uuid and bearer token"
    end

    home = Home.new
    home.town = $home[:town]
    home.name = name
    home.description = description
    home.domain_name = domain_name
    home.content_version = content_version

    unless home.valid?
      error 422, home.errors.messages.to_json
    end

    return { uuid: params[:uuid] }.to_json
  end

  # DELETE
  delete '/api/u/:user_uuid/homes/:uuid' do
    ensure_correct_headings
    find_user_by_bearer_token
    puts "# delete - DELETE /api/homes/:uuid"
    content_type :json

    if params[:uuid] != $home[:uuid]
      error 404, "failed to find home with provided uuid and bearer token"
    end

    $home = {}
    { message: "House deleted successfully" }.to_json
  end
end

# This is what will run the server
TerraTownsMockServer.run!