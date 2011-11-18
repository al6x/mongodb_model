module Mongo::Model
  include Mongo::Object

  inherited do
    unless is?(Array) or is?(Hash)
      alias_method :eql?, :model_eql?
      alias_method :==, :model_eq?
    end
  end

  # Equality.

  def model_eql? o
    return true if equal? o
    self.class == o.class and self == o
  end

  def model_eq? o
    return true if equal? o
    return false unless o.is_a? Mongo::Model

    variables = {}.tap do |h|
      persistent_instance_variable_names.each{|n| h[n] = instance_variable_get(n)}
    end

    o_variables = {}.tap do |h|
      o.persistent_instance_variable_names.each{|n| h[n] = o.instance_variable_get(n)}
    end

    variables == o_variables
  end

  protected
    # Traversing models.

    def embedded_models recursive = false
      [].tap{|a| each_embedded(recursive){|m| a.add m}}
    end

    def each_embedded recursive = false, &block
      self.class.embedded.each do |name|
        if o = instance_variable_get(name)
          _each_embedded o, recursive, &block
        end
      end
    end

    # Hash or Array also can be the Model by itsef, so we need to check
    # for presence both `:each_embedded` and `:each_value` methods.
    def _each_embedded o, recursive, &block
      # If o is model adding it and its children.
      if o.respond_to? :each_embedded
        block.call o
        o.each_embedded recursive, &block if recursive
      end

      # If o is Hash or Array, iterating and adding all models from there,
      # recursivelly, hashes and arrays can be nested in any order.
      if o.respond_to? :each_value
        o.each_value do |o|
          _each_embedded o, recursive, &block
        end
      end
    end

  module ClassMethods
    inheritable_accessor :_embedded, []

    def embedded *list
      list.collect!{|n| :"@#{n}"}
      if list.empty? then _embedded else _embedded.push(*list) end
    end
  end
end