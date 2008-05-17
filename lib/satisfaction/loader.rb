require 'net/http'
require 'uri'


class Sfn::Loader
  require 'satisfaction/cache/hash'
  require 'satisfaction/cache/memcache'

  CacheRecord = Struct.new(:url, :etag, :body)
  attr_reader :cache
  attr_reader :options
  
  def initialize(options={})
    @options = options.reverse_merge({:cache => :hash})
    reset_cache
  end
  
  def reset_cache
    @cache =  case @options[:cache]
              when :hash then HashCache.new
              when :memcache then MemcacheCache.new(@options[:memcache] || {})
              else
                raise ArgumentError, "Invalid cache spec: #{@options[:cache]}"
              end
  end
  
  def get(url, options = {})
    uri = get_uri(url)
    request = Net::HTTP::Get.new(uri.request_uri)
    cache_record = cache.get(uri)
    
    if cache_record && !options[:force]
      request["If-None-Match"] = cache_record.etag
    end
    
    http = Net::HTTP.new(uri.host, uri.port)
    add_authentication(request, http, options)
    response = execute(http, request)
    
    case response
    when Net::HTTPNotModified
      return [:ok, cache_record.body]
    when Net::HTTPSuccess
      cache.put(uri, response)
      [:ok, response.body]
    when Net::HTTPMovedPermanently
      limit = options[:redirect_limit] || 3
      raise ArgumentError, "Too many redirects" unless limit > 0 #TODO: what is a better error here?
      get(response['location'], options.merge(:redirect_limit => limit - 1))
    when Net::HTTPBadRequest
      [:bad_request, response.body]
    when Net::HTTPForbidden
      [:forbidden, response.body]
    when Net::HTTPUnauthorized
      [:unauthorized, response.body]
    else
      raise "Explode: #{response.to_yaml}"
    end
  end
  
  def post(url, options)
    uri = get_uri(url)
    form = options[:form] || {}
    method_klass =  case options[:method]
                    when :put     then Net::HTTP::Put
                    when :delete  then Net::HTTP::Delete
                    else
                       Net::HTTP::Post
                    end
                    
    request = method_klass.new(uri.request_uri)
    
    request.set_form_data(form)
    
    http = Net::HTTP.new(uri.host, uri.port)
    add_authentication(request, http, options)
    response = execute(http, request)
    
    case response
    when Net::HTTPUnauthorized
      [:unauthorized, response.body]
    when Net::HTTPBadRequest
      [:bad_request, response.body]
    when Net::HTTPForbidden
      [:forbidden, response.body]
    when Net::HTTPSuccess
      [:ok, response.body]
    else
      raise "Explode: #{response.to_yaml}"
    end
  end
  
  private
  def execute(http, request)
    http.start{|http| http.request(request) }
  end
  
  def get_uri(url)
    case url
    when URI then url
    when String then URI.parse(url)
    else
      raise ArgumentError, "Invalid uri, please use a String or URI object"
    end
  end
  
  def add_authentication(request, http, options)
    if options[:user]
      request.basic_auth(options[:user], options[:password])
    elsif options[:consumer]
      request.oauth!(http, options[:consumer], options[:token])
    end
  end
end

