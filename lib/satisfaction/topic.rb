class Topic < Resource
  attributes :subject, :style, :content, :reply_count, :follower_count
  attribute :last_active_at, :type => Time
  attribute :created_at, :type => Time
  attribute :author, :type => Person
  
  def path
    "/topics/#{@id}"
  end
  
  def setup_associations
    has_many :replies, :url => "#{path}/replies"
    has_many :people, :url => "#{path}/people"
    has_many :products, :url => "#{path}/products"
    has_many :tags, :url => "#{path}/tags"
  end
end