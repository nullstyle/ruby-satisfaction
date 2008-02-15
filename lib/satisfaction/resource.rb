require 'forwardable'

class Resource < HasSatisfaction
  require 'satisfaction/resource/attributes'
  include ::Associations
  include Attributes
  attr_reader :id
  
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
    "<#{self.class.name} #{attributes.map{|k,v| "#{k}: #{v}"}.join(' ') if !attributes.nil?}>"
  end
end

class ResourceCollection < HasSatisfaction
  attr_reader :klass
  
  def initialize(klass, satisfaction, path)
    super satisfaction
    @klass = klass
    @path = path
  end
  
  def page(number, options={})
    Page.new(@klass, number, @path, satisfaction, options)
  end
  
  def get(id, options={})
    klass.new(id, satisfaction)
  end
end

class Page < HasSatisfaction
  attr_reader :total
  
  extend Forwardable
  def_delegator :items, :first
  def_delegator :items, :last
  def_delegator :items, :each
  def_delegator :items, :each_with_index    
  def_delegator :items, :inject    
  def_delegator :items, :reject    
  def_delegator :items, :select    
  def_delegator :items, :map
  def_delegator :items, :[]
  def_delegator :items, :length
  def_delegator :items, :to_a
  def_delegator :items, :empty?
  
  def initialize(klass, number, path, satisfaction, options)
    super(satisfaction)    
    @klass = klass
    @number = number
    @path = path
    @options = options
  end
  
  # Retrieve the items for this page
  # * Caches
  def items
    @data ||= load
  end
  
  def loaded?
    @data.nil?
  end
  
  def next?
    last_item = @number * length
    @total > last_item
  end
  
  def load
    results = satisfaction.get("#{@path}.json", @options.merge(:page => @number))
    json = JSON.parse(results)
    @total = json["total"]
    json["data"].map do |result|
      @klass.decode_sfn(result, satisfaction)
    end
  end
end