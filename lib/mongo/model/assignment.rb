module Mongo::Model::Assignment
  class Dsl < BasicObject
    def initialize model
      @model = model
    end

    protected
      def method_missing m, *args
        args.unshift m
        @model.assign *args
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
    super()
    set attributes if attributes
  end

  module ClassMethods
    inheritable_accessor :_assign, nil

    def assign *args, &block
      if block
        dsl = ::Mongo::Model::Assignment::Dsl.new self
        dsl.instance_eval &block
      else
        args.size.must.be_in 2..3
        attr_name = args.shift
        attr_name.must.be_a Symbol

        if args.first.is_a? Class
          type, mass_assignment = args
          mass_assignment ||= false
          type.must.respond_to :cast
        else
          type, mass_assignment = nil, args.first
        end

        self._assign ||= {}
        _assign[attr_name] = [type, mass_assignment]
      end
    end
  end
end