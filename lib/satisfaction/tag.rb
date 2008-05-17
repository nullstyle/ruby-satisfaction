class Sfn::Tag < Sfn::Resource
  attributes :name

  def path
    "/tags/#{@id}"
  end
  
  def setup_associations
    has_many :topics, :url => "#{path}/topics"
    has_many :companies, :url => "#{path}/companies"
    has_many :products, :url => "#{path}/products"
  end

end