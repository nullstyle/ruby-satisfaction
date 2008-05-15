module Satisfaction::Resource::Attributes
  def self.included(base)
    base.class_eval do
      extend ClassMethods
      include InstanceMethods
      attr_reader :attributes
    end
  end
  
  module ClassMethods

    def attributes(*names)
      options = names.extract_options!
      
      names.each do |name|
        attribute name, options unless name.blank?
      end
    end

    def attribute(name, options)
      options.reverse_merge!(:type => 'nil')
      raise "Name can't be empty" if name.blank?
      
      class_eval <<-EOS
        def #{name}
          self.load unless self.loaded?
          @#{name} ||= decode_raw_attribute(@attributes['#{name}'], #{options[:type]}) if @attributes
        end
      EOS
    end
  
  end
  
  module InstanceMethods
    def attributes=(value) 
      @attributes = value.with_indifferent_access
    end
    
    private
    def decode_raw_attribute(value, type)
      if type.respond_to?(:decode_sfn)
        type.decode_sfn(value, self.satisfaction)
      else
        value
      end
    end
  end
end


class Time
  def self.decode_sfn(value, satisfaction)
    parse(value)
  end
end

class Satisfaction::Resource
  def self.decode_sfn(value, satisfaction)
    case value
    when Hash
      id = value['id']
      returning(new(id, satisfaction)){|r| r.attributes = value}
    else
      new(value, satisfaction)
    end
  end
end