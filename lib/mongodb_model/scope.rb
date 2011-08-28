module Mongo::Model::Scope
  class ScopeProxy < BasicObject
    def initialize model, scope
      @model, @scope = model, scope
    end

    def class
      ::Mongo::Model::Scope::ScopeProxy
    end

    def reverse_merge! scope
      @scope = scope.merge @scope
    end

    def inspect
      "#<ScopeProxy:{#{scope.inspect}}>"
    end
    alias_method :to_s, :inspect

    protected
      attr_reader :model, :scope

      def method_missing method, *args, &block
        model.with_scope scope do
          result = model.send method, *args, &block
          result.reverse_merge! scope if result.class == ::Mongo::Model::Scope::ScopeProxy
          result
        end
      end
  end

  module ClassMethods
    def current_scope
      scope, exclusive = Thread.current[:mongo_model_scope]
      if exclusive
        scope
      elsif scope
        default_scope.merge scope
      else
        default_scope
      end
    end

    def with_exclusive_scope options = {}, &block
      with_scope options, true, &block
    end

    def with_scope options = {}, exclusive = false, &block
      previous_options, previous_exclusive = Thread.current[:mongo_model_scope]
      raise "exclusive scope already applied!" if previous_exclusive

      begin
        options = previous_options.merge options if previous_options and !exclusive
        Thread.current[:mongo_model_scope] = [options, exclusive]
        return block.call
      ensure
        Thread.current[:mongo_model_scope] = [previous_options, false]
      end
    end

    inheritable_accessor :_default_scope, -> {{}}
    def default_scope *args, &block
      if block
        self._default_scope = block
      elsif !args.empty?
        args.size.must == 1
        args.first.must_be.a Hash
        scope = args.first
        self._default_scope = -> {args.first}
      else
        _default_scope.call
      end
    end

    def scope name, options = nil, &block
      model = self
      metaclass.define_method name do
        scope = (block && block.call) || options
        ScopeProxy.new model, scope
      end
    end


    #
    # finders
    #
    def count selector = {}, opts = {}
      super current_scope.merge(selector), opts
    end

    def first selector = {}, opts = {}
      super current_scope.merge(selector), opts
    end

    def each selector = {}, opts = {}, &block
      super current_scope.merge(selector), opts, &block
    end
  end
end