class Company < Resource
  
  attributes :domain, :name, :logo, :description
  
  def path
    "/companies/#{@id}"
  end
  
  def setup_associations
    has_many :people, :url => "#{path}/people"
    has_many :topics, :url => "#{path}/topics"
    has_many :products, :url => "#{path}/products"
    has_many :employees, :url => "#{path}/employees", :class_name => 'Person'
    has_many :tags, :url => "#{path}/tags"
    
  end
  
end