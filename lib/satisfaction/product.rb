class Product < Resource
  attributes :name, :url, :image, :description
  attribute :last_active_at, :type => Time
  attribute :created_at, :type => Time
  
  def path
    "/products/#{@id}"
  end
  
  def setup_associations
    has_many :topics, :url => "#{path}/topics"
    has_many :people, :url => "#{path}/people"
    has_many :companies, :url => "#{path}/companies"
    has_many :tags, :url => "#{path}/tags"
  end

end