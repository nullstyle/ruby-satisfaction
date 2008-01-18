
class Loader::MemcacheCache
  def initialize(options = {})
    options = options.reverse_merge({:servers => ['127.0.0.1:11211'], :namespace => 'satisfaction', })
    @m = MemCache.new(options.delete(:servers), options)
  end
  
  def put(url, response)
    return nil if response["ETag"].blank?
    
    @m[url.to_s] = Loader::CacheRecord.new(url, response["ETag"], response.body)
  end
  
  def get(url)
    @m[url.to_s]
  end
end