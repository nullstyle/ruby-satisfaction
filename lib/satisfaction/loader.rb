require 'net/http'
require 'uri'


class Loader
  require 'satisfaction/cache/hash'
  require 'satisfaction/cache/memcache'

  CacheRecord = Struct.new(:url, :etag, :body)
  attr_reader :cache
  attr_reader :options
  
  def initialize(options={})
    @options = options.reverse_merge({:cache => :hash})
    @cache =  case @options[:cache]
              when :hash then Loader::HashCache.new
              when :memcache then Loader::MemcacheCache.new(@options[:memcache] || {})
              else
                raise ArgumentError, "Invalid cache spec: #{@options[:cache]}"
              end
  end
  
  def get(url, options = {})
    options = options.reverse_merge({:limit => 3})
    limit = options[:limit]
    
    url = case url
          when URI then url
          when String then URI.parse(url)
          else
            raise ArgumentError, "Invalid uri, please use a String or URI object"
          end
    
    path = url.path.blank? ? '/' : url.path
    request = Net::HTTP::Get.new(path)
    cache_record = cache.get(url)
    if cache_record && !options[:force]
      request["If-None-Match"] = cache_record.etag
    end
    
    response = execute(url, request)
    
    case response
    when Net::HTTPNotModified
      return cache_record.body
    when Net::HTTPSuccess
      cache.put(url, response)
      response.body
    when Net::HTTPMovedPermanently
      raise ArgumentError, "Too many redirects" unless limit > 0 #TODO: what is a better error here?
      get(response['location'], options.merge(:limit => limit - 1))
    else
      raise "Explode: #{response.to_yaml}"
    end
  end
  
  private
  def execute(url, request)
    Net::HTTP.start(url.host, url.port) {|http| http.request(request) }
  end
end

