module Mongo::Model::Conversion
  def model_to_json *args, &block
    to_hash(*args, &block).to_json
  end

  def model_to_xml *args, &block
    to_hash(*args, &block).to_xml
  end

  alias_method :to_json, :model_to_json
  alias_method :to_xml, :model_to_xml

  inherited do
    alias_method :to_json, :model_to_json
    alias_method :to_xml, :model_to_xml

    # Hack to supress ActiveSupport as_json.
    alias_method :as_json, :model_to_json
    alias_method :as_xml, :model_to_xml
  end

  def to_hash options = {}
    if profile = options[:profile]
      raise "no other optins are allowed when using :profile option!" if options.size > 1
      profile_options = self.class.profiles[profile] || raise("profile :#{profile} not defined for #{self.class}!")
      to_hash profile_options.merge(_profile: profile)
    else
      options.validate_options! :only, :except, :methods, :errors, :_profile
      child_options = options[:_profile] ? {profile: options[:_profile]} : {}

      instance_variables = self.persistent_instance_variable_names

      if only = options[:only]
        instance_variables &= Array(only).collect{|n| :"@#{n}"}
      elsif except = options[:except]
        instance_variables -= Array(except).collect{|n| :"@#{n}"}
      end

      result = {}
      instance_variables.each do |iv_name|
        value = instance_variable_get iv_name
        value = convert_object value, :to_hash, child_options
        result[iv_name[1.. -1].to_sym] = value
      end

      methods = options[:methods] ? Array(options[:methods]) : []
      methods.each do |method|
        value = send method
        value = convert_object value, :to_hash, child_options
        result[method.to_sym] = value
      end

      with_errors = options.include?(:errors) ? options[:errors] : true
      if with_errors and !(errors = self.errors).empty?
        errors = {}
        self.errors.each{|k, v| errors[k.to_sym] = v}
        result[:errors] = errors
      end

      result
    end
  end

  module ClassMethods
    inheritable_accessor :profiles, {}
    def profile name, options = {}
      profiles[name] = options
    end
  end
end