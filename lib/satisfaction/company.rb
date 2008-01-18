class Company < Resource
  
  attributes :domain, :name, :logo
  
  def path
    "/companies/#{@id}"
  end
  
  def setup_associations
    has_many :people, :url => "#{path}/people"
    has_many :topics, :url => "#{path}/topics"
    has_many :products, :url => "#{path}/people"
  end
  
end