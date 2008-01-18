require 'rubygems'
require 'active_support'
require 'hpricot'
require 'json'
gem('memcache-client')
require 'memcache'

require 'satisfaction/has_satisfaction'
require 'satisfaction/loader'
require 'satisfaction/associations'
require 'satisfaction/resource'

require 'satisfaction/company'
require 'satisfaction/person'
require 'satisfaction/topic'
# require 'satisfaction/tag'
# require 'satisfaction/product'
# require 'satisfaction/reply'

class Satisfaction
  include Associations
  
  attr_reader :options
  attr_reader :loader

  
  def initialize(options={})
    @options = options.reverse_merge({:root => "http://api.getsatisfaction.com", :autoload => false})
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
  
  def url(path)
    URI.parse("#{@options[:root]}#{path}")
  end
  
  def get(path)
    url = self.url(path)
    @loader.get(url)
  end
  
  private
  def validate_options
    raise ArgumentError, "You must specify a location for the API's service root" if options[:root].blank?
  end
end
