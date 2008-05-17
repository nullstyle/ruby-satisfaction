require 'satisfaction/external_dependencies'
module Sfn
end
class Satisfaction
  # ==================
  # = Core Utilities =
  # ==================
  require 'satisfaction/util'
  require 'satisfaction/has_satisfaction'
  require 'satisfaction/associations'
  require 'satisfaction/resource'
  require 'satisfaction/loader'
  require 'satisfaction/identity_map'
  
  
  # =============
  # = Resources =
  # =============
  
  require 'satisfaction/company'
  require 'satisfaction/person'
  require 'satisfaction/topic'
  require 'satisfaction/tag'
  require 'satisfaction/product'
  require 'satisfaction/reply'
  
  # =============
  
  include Associations
  
  attr_reader :options
  attr_reader :loader
  attr_reader :consumer
  attr_reader :token
  attr_reader :identity_map

  
  def initialize(options={})
    @options = options.reverse_merge({
      :root => "http://api.getsatisfaction.com", 
      :autoload => false,
      :request_token_url => 'http://getsatisfaction.com/api/request_token',
      :access_token_url => 'http://getsatisfaction.com/api/access_token',
      :authorize_url => 'http://getsatisfaction.com/api/authorize',
    })
    @loader = Sfn::Loader.new
    @identity_map = Sfn::IdentityMap.new
    
    has_many :companies, :url => '/companies'
    has_many :people, :url => '/people'
    has_many :topics, :url => '/topics'
    has_many :replies, :url => '/replies'
    has_many :tags, :url => '/tags'
    has_many :products, :url => '/products'
  end
  
  def satisfaction
    self
  end
  
  def me
    me = satisfaction.identity_map.get_record(Me, 'me') do
      Sfn::Me.new('me', satisfaction)
    end
    
    if me.loaded?
      me
    else
      me.load 
    end
  end
  
  def autoload?
    options[:autoload]
  end
  
  def set_basic_auth(user, password)
    identity_map.expire_record(Me, 'me')
    @user = user
    @password = password
  end
  
  def set_consumer(key, secret)
    identity_map.expire_record(Me, 'me')
    @consumer = OAuth::Consumer.new(key, secret)
  end
  
  def set_token(token, secret)
    identity_map.expire_record(Me, 'me')
    @token = OAuth::Token.new(token, secret)
  end
  
  def request_token
    result, body = *@loader.get("#{options[:request_token_url]}", :force => true, :consumer => @consumer, :token => nil)
    raise "Could not retrieve request token" unless result == :ok
    response = CGI.parse(body)
    OAuth::Token.new(response["oauth_token"], response["oauth_token_secret"])
  end
  
  def authorize_url(token)
    "#{options[:authorize_url]}?oauth_token=#{token.token}"
  end
  
  def access_token(token)
    result, body = *@loader.get("#{options[:access_token_url]}", :force => true, :consumer => @consumer, :token => token)
    raise "Could not retrieve access token" unless result == :ok
    response = CGI.parse(body)
    OAuth::Token.new(response["oauth_token"], response["oauth_token_secret"])
  end
  
  
  def url(path, query_string={})
    qs = query_string.map{|kv| URI.escape(kv.first.to_s) + "=" + URI.escape(kv.last.to_s)}.join("&")
    URI.parse("#{@options[:root]}#{path}?#{qs}")
  end
  
  def get(path, query_string={})
    url = self.url(path, query_string)
    
    @loader.get(url, :consumer => @consumer, :token => @token, :user => @user, :password => @password)
      
  end
  
  def post(path, form={})
    url = self.url(path)
    @loader.post(url, 
      :consumer => @consumer, 
      :token => @token, 
      :user => @user, 
      :password => @password,
      :form => form)
  end
  
  def delete(path)
    url = self.url(path)
    @loader.post(url,
      :consumer => @consumer, 
      :token => @token, 
      :user => @user, 
      :password => @password,
      :method => :delete)
  end
  
  def put(path, form={})
    url = self.url(path)
    @loader.post(url, 
      :consumer => @consumer, 
      :token => @token, 
      :user => @user, 
      :password => @password,
      :method => :put,
      :form => form)
  end
  
  private
  def validate_options
    raise ArgumentError, "You must specify a location for the API's service root" if options[:root].blank?
  end
end
