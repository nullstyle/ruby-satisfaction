module Associations
  def has_many(resource, options={})
    class_name = options[:class_name] || resource.to_s.classify
    eval <<-EOS
      def #{resource}
        @#{resource} ||= ResourceCollection.new(#{class_name}, self.satisfaction, '#{options[:url]}')
      end
    EOS
  end
  
  # def belongs_to(resource, options={})
  #   class_name = options[:class_name] || resource.to_s.classify
  #   eval <<-EOS
  #     def #{resource}
  #       @#{resource} ||= #{class_name}.new(#{resource}_id, self.satisfaction)
  #     end
  #   EOS
  # end
end