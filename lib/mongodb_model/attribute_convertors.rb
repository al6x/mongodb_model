require 'json'
require 'yaml'

module Mongo::Model::AttributeConvertors
  CONVERTORS = {
    line: {
      from_string: -> s {(s || "").split(',').collect{|s| s.strip}},
      to_string:   -> v {v.join(', ')}
    },
    column: {
      from_string: -> s {(s || "").split("\n").collect{|s| s.strip}},
      to_string:   -> v {v.join("\n")}
    },
    yaml: {
      from_string: -> s {YAML.load s rescue {}},
      to_string:   -> v {v.to_yaml.strip}
    },
    json: {
      from_string: -> s {JSON.parse s rescue {}},
      to_string:   -> v {v.to_json.strip}
    }
  }

  module ClassMethods
    def available_as_string name, converter_name
      converter = CONVERTORS[converter_name]
      raise "unknown converter name :#{converter_name} for :#{name} field!" unless converter

      from_string, to_string = converter[:from_string], converter[:to_string]
      name_as_string = "#{name}_as_string".to_sym
      define_method name_as_string do
        _cache[name_as_string] ||= to_string.call(send(name))
      end

      define_method "#{name_as_string}=" do |value|
        _cache.delete name_as_string
        self.send "#{name}=", from_string.call(value)
      end
    end

    def available_as_yaml name
      raise "delimiter not specified for :#{name} field!" unless delimiter
      method = "#{name}_as_string"
      define_method method do
        self.send(name).join(delimiter)
      end
      define_method "#{method}=" do |value|
        value = (value || "").split(delimiter.strip).collect{|s| s.strip}
        self.send "#{name}=", value
      end
    end
  end

end