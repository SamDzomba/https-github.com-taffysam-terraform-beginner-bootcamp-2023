require 'sinatra'
require 'json'
require 'pry'
require 'active_model'
# We will emaulate mock for having a state or database for this dev server
# by setting a global variable. You shoule never use a gloabl variable
# in Production

$home = {}

class Home
  attr_accessor :town, :name, :description, :domain_name, :content_version

  def initialize
    @town = nil
    @name = nil
    @description = nil
    @domain_name = nil
    @content_version = nil
  end

  def valid?
    errors.clear
    validate_town
    validate_name
    validate_description
    validate_domain_name
    validate_content_version
    errors.empty?
  end

  def errors
    @errors ||= {}
  end

  private

  def validate_town
    unless ['melomaniac-mansion', 'Cooker Cove', 'Video Valley', 'The Nomad Pad', 'Gamer Grotto'].include?(town)
      errors[:town] = 'Town is invalid'
    end
  end

  def validate_name
    errors[:name] = 'Name is required' if name.nil? || name.empty?
  end

  def validate_description
    errors[:description] = 'Description is required' if description.nil? || description.empty?
  end

  def validate_domain_name
    unless domain_name =~ /\.cloudfront\.net\z/
      errors[:domain_name] = 'Domain must be from .cloudfront.net'
    end
  end

  def validate_content_version
    errors[:content_version] = 'Content version must be an integer' unless content_version.is_a?(Integer)
  end
end

# ... the rest of your code ...

class TerraTownsMockServer < Sinatra::Base
  # Your Sinatra routes and methods here.
end

TerraTownsMockServer.run!
