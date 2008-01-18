class Resource < HasSatisfaction
  require 'satisfaction/resource/attributes'
  include ::Associations
  include Attributes
  
  def initialize(id, satisfaction)
    super satisfaction
    @id = id
    setup_associations if respond_to?(:setup_associations)
  end
  
  def path
    raise "path not implemented in Resource base class"
  end
  
  def load
    result = satisfaction.get("#{path}.json")    
    self.attributes = JSON.parse(result)
    self
  end
  
  def loaded?
    !@attributes.nil?
  end
  
  def inspect
    "<#{self.class.name} #{attributes.map{|k,v| "#{k}: #{v}"}.join(' ')}>"
  end
end

class ResourceCollection < HasSatisfaction
  attr_reader :klass
  
  def initialize(klass, satisfaction, path)
    super satisfaction
    @klass = klass
    @path = path
  end
  
  def page(number)
    results = satisfaction.get("#{@path}.json?page=#{number}")
    JSON.parse(results).map do |result|
      klass.decode_sfn(result, satisfaction)
    end
  end
  
  def get(id, options={})
    klass.new(id, satisfaction)
  end
end

class Page < HasSatisfaction
  def initialize(klass, number, url, satisfaction)
    super(satisfaction)
    @loaded = false
    
    load if satisfaction.autoload?
  end
  
  def loaded?
    @loaded
  end
  
  def load
    
  end
end