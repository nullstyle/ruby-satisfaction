module Associations
  def has_many(resource, options={})
    class_name = options[:class_name] || "Sfn::#{resource.to_s.classify}"
    eval <<-EOS
      def #{resource}
        @#{resource} ||= Sfn::ResourceCollection.new(#{class_name}, self.satisfaction, '#{options[:url]}')
      end
    EOS
  end
  
  def belongs_to(resource, options={})
    class_name = options[:class_name] || "Sfn::#{resource.to_s.classify}"
    parent_id = options[:parent_attribute] || "#{resource}_id"
    eval <<-EOS
      def #{resource}
        @#{resource} ||= #{class_name}.new(#{parent_id}, self.satisfaction)
      end
    EOS
  end
end