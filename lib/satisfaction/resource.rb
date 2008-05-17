require 'forwardable'

class Sfn::Resource < Sfn::HasSatisfaction
  require 'satisfaction/resource/attributes'
  include ::Associations
  include Attributes
  attr_reader :id
  include Sfn::Util
  
  
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
    
    if result.first == :ok
      self.attributes = JSON.parse(result.last)
      was_loaded(result.last)
      self
    else
      result
    end
  end
  
  def was_loaded(result)
    #override this to augment post-loading behavior
  end
  
  def delete
    satisfaction.delete("#{path}.json")
  end
  
  def put(attrs)
    params = requestify(attrs, self.class.name.underscore)
    result = satisfaction.put("#{path}.json", params)
    
    if result.first == :ok
      json = JSON.parse(result.last)
      self.attributes = json
      self
    else
      result
    end
  end
  
  def loaded?
    !@attributes.nil?
  end
  
  def inspect
    if loaded?
      "<#{self.class.name} #{attributes.map{|k,v| "#{k}: #{v}"}.join(' ') if !attributes.nil?}>"
    else
      "<#{self.class.name} #{path} UNLOADED>"      
    end
  end

end

class Sfn::ResourceCollection < Sfn::HasSatisfaction
  attr_reader :klass
  attr_reader :path
  include Sfn::Util
  
  def initialize(klass, satisfaction, path)
    super satisfaction
    @klass = klass
    @path = path
  end
  
  def page(number, options={})
    Sfn::Page.new(self, number, options)
  end
  
  def get(id, options={})
    #options currently ignored
    satisfaction.identity_map.get_record(klass, id) do
      klass.new(id, satisfaction)
    end
  end
  
  def post(attrs)
    params = requestify(attrs, klass.name.underscore)
    result = satisfaction.post("#{path}.json", params)
    
    if result.first == :ok
      json = JSON.parse(result.last)
      id = json["id"]
      obj = klass.new(id, satisfaction)
      obj.attributes = json
      obj
    else
      result
    end
  end
  
  def [](*key)
    options = key.extract_options!
    case key.length
    when 1
      get(key, options)
    when 2
      page(key.first, options.merge(:limit => key.last))
    else
      raise ArgumentError, "Invalid Array arguement, only use 2-element array: :first is the page number, :last is the page size"
    end
  end
  
end

class Sfn::Page < Sfn::HasSatisfaction
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
        
    result = satisfaction.get("#{@path}.json", @options.merge(:page => @page))
    
    if result.first == :ok
      json = JSON.parse(result.last)
      @total = json["total"]
    
      @data = json["data"].map do |result|
        obj = @klass.decode_sfn(result, satisfaction)
        satisfaction.identity_map.get_record(@klass, obj.id) do
          obj
        end
      end
    else
      result
    end
  end
end