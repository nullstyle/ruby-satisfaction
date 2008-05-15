class Sfn::Person < Sfn::Resource
  attributes :name, :id, :photo, :tagline
  
  def path
    "/people/#{@id}"
  end
  
  def setup_associations
    has_many :replies, :url => "#{path}/replies"
    has_many :topics, :url => "#{path}/topics"
    has_many :followed_topics, :url => "#{path}/followed/topics", :class_name => 'Sfn::Topic'
  end
end

class Me < Sfn::Person  
  def path
    loaded? ? super : "/me"
  end
  
  def was_loaded(result)
    @id = self.attributes["id"]
    setup_associations
  end
end