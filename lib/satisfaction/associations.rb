module Associations
  def has_many(resource, options={})
    class_name = options[:class_name] || resource.to_s.classify
    eval <<-EOS
      def #{resource}
        @#{resource} ||= ResourceCollection.new(#{class_name}, self.satisfaction, '#{options[:url]}')
      end
    EOS
  end
end