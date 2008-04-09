module Satisfaction::Util
  def requestify(parameters, prefix=nil)
    parameters.inject({}) do |results, kv|
      if Hash === kv.last
        results = results.merge(requestify(kv.last, "#{prefix}[#{kv.first}]"))
      else
        results["#{prefix}[#{kv.first}]"] = kv.last
      end
        
      results
    end
  end
end