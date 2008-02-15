class Reply < Resource
  attributes :content, :star_count, :topic_id
  attribute :created_at, :type => Time
  attribute :author, :type => Person
  
  def path
    "/#{topic_id}/replies/#{id}"
  end
  
  def setup_associations

  end
end