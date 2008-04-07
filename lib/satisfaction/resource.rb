require 'forwardable'

class Resource < Satisfaction::HasSatisfaction
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

class ResourceCollection < Satisfaction::HasSatisfaction
  attr_reader :klass
  attr_reader :path
  
  def initialize(klass, satisfaction, path)
    super satisfaction
    @klass = klass
    @path = path
  end
  
  def page(number, options={})
    Page.new(self, number, options)
  end
  
  def get(id)
    satisfaction.identity_map.get_record(klass, id) do
      klass.new(id, satisfaction)
    end
  end
  
  
end

class Page < Satisfaction::HasSatisfaction
  attr_reader :total
  attr_reader :collection
  
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
  
  def initialize(collection, page, options={})
    super(collection.satisfaction)
    @collection = collection
    @klass = collection.klass
    @page = page
    @path = collection.path
    @options = options
    @options[:limit] ||= 10
  end
  
  # Retrieve the items for this page
  # * Caches
  def items
    load
    @data
  end
  
  def loaded?
    !@data.nil?
  end
  
  def page_size
    @options[:limit]
  end
  
  def next?
    load #this loads the data, we shold probably make load set the ivar instead of items ;)
    last_item = @page * page_size
    @total > last_item
  end
  
  def next
    return nil unless next?
    self.class.new(@collection, @page + 1, @options)
  end
  
  
  def prev?
    @page > 1
  end
  
  def prev
    return nil unless prev?
    self.class.new(@collection, @page - 1, @options)
  end
  
  def page_count
    result = @total / length
    result += 1 if @total % length != 0
    result
  end
  
  def load(force=false)
    return @data if loaded? && !force
    
    results = satisfaction.get("#{@path}.json", @options.merge(:page => @page))
    json = JSON.parse(results)
    @total = json["total"]
    
    @data = json["data"].map do |result|
      obj = @klass.decode_sfn(result, satisfaction)
      satisfaction.identity_map.get_record(@klass, obj.id) do
        obj
      end
    end
  end
end