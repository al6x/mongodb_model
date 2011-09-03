module Mongo::Model::Assignment
  class Dsl < BasicObject
    def initialize
      @attributes = {}
    end

    def self.const_missing name
      # BasicObject doesn't have access to any constants like String, Symbol, ...
      ::Object.const_get name
    end

    def to_h; attributes end

    protected
      attr_reader :attributes

      def method_missing attribute_name, *args
        attribute_name.must_be.a Symbol

        args.size.must_be.in 1..2
        if args.first.is_a? Class
          type, mass_assignment = args
          mass_assignment ||= false
          type.must.respond_to :cast
        else
          type, mass_assignment = nil, args.first
        end

        attributes[attribute_name] = [type, mass_assignment]
      end
  end

  def set attributes, options = {}
    if rules = self.class._assign
      force = options[:force]
      attributes.each do |n, v|
        n = n.to_sym
        type, mass_assignment = rules[n]
        if mass_assignment or force
          v = type.cast(v) if type
          send "#{n}=", v
        else
          raise "mass assignment for :#{n} attribute not allowed!"
        end
      end
    else
      attributes.each{|n, v| send "#{n}=", v}
    end
    self
  end

  def set! attributes, options = {}
    set attributes, options.merge(force: true)
  end

  def initialize attributes = nil
    super
    set attributes if attributes
  end

  module ClassMethods
    inheritable_accessor :_assign, nil

    def assign &block
      dsl = ::Mongo::Model::Assignment::Dsl.new
      dsl.instance_eval &block
      self._assign = (_assign || {}).merge dsl.to_h
    end
  end
end