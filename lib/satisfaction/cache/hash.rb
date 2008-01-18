class Loader::HashCache
  def initialize
    @cached_responses = {}
  end
  
  def put(url, response)
    return nil if response["ETag"].blank?
    @cached_responses[url.to_s] = Loader::CacheRecord.new(url, response["ETag"], response.body)
  end
  
  def get(url)
    @cached_responses[url.to_s]
  end
end