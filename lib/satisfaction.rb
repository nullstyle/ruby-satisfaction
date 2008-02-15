require 'rubygems'
require 'active_support'
require 'hpricot'
require 'json'
gem('memcache-client')
require 'memcache'

require 'oauth'
require 'oauth/signature/hmac/sha1'
require 'oauth/client/net_http'

require 'satisfaction/has_satisfaction'
require 'satisfaction/loader'
require 'satisfaction/associations'
require 'satisfaction/resource'

require 'satisfaction/company'
require 'satisfaction/person'
require 'satisfaction/topic'
# require 'satisfaction/tag'
# require 'satisfaction/product'
require 'satisfaction/reply'

class Satisfaction
  include Associations
  
  attr_reader :options
  attr_reader :loader
  attr_reader :consumer
  attr_reader :token

  
  def initialize(options={})
    @options = options.reverse_merge({
      :root => "http://api.getsatisfaction.com", 
      :autoload => false,
      :request_token_url => 'http://getsatisfaction.com/api/request_token',
      :access_token_url => 'http://getsatisfaction.com/api/access_token',
      :authorize_url => 'http://getsatisfaction.com/api/authorize',
    })
    @loader = Loader.new
    
    has_many :companies, :url => '/companies'
    has_many :people, :url => '/people'
    has_many :topics, :url => '/topics'
    has_many :tags, :url => '/tags'
    has_many :products, :url => '/people'
  end
  
  def satisfaction
    self
  end
  
  def autoload?
    options[:autoload]
  end
  
  def set_consumer(key, secret)
    @consumer = OAuth::Consumer.new(key, secret)
  end
  
  def set_token(token, secret)
    @token = OAuth::Token.new(token, secret)
  end
  
  def request_token
    @loader.get("#{options[:request_token_url]}", :force => true, :consumer => @consumer, :token => nil)
  end
  
  
  def url(path, query_string={})
    qs = query_string.map{|kv| URI.escape(kv.first.to_s) + "=" + URI.escape(kv.last.to_s)}.join("&")
    URI.parse("#{@options[:root]}#{path}?#{qs}")
  end
  
  def get(path, query_string={})
    url = self.url(path, query_string)
    @loader.get(url)
  end
  
  private
  def validate_options
    raise ArgumentError, "You must specify a location for the API's service root" if options[:root].blank?
  end
end
