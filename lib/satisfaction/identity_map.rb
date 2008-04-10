class Satisfaction::IdentityMap
  attr_reader :records, :pages
  
  def initialize
    @records = {}
    @pages = {}
  end
  
  def get_record(klass, id, &block)
    result = @records[[klass, id]]
    result ||= begin
      obj = yield(klass, id)
      @records[[klass, id]] = obj
    end
    result
  end
  
  def expire_record(klass, id)
    @records[[klass, id]] = nil
  end
end