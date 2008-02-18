class Satisfaction::HasSatisfaction
  attr_reader :satisfaction
  
  def initialize(satisfaction)
    @satisfaction = satisfaction
  end
  
end