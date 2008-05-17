class Sfn::Reply < Sfn::Resource
  attributes :content, :star_count, :topic_id
  attribute :created_at, :type => Time
  attribute :author, :type => Sfn::Person
  
  def path
    "/replies/#{id}"
  end
  
  def setup_associations
    belongs_to :topic
  end
end