module Mongo::Model::Scope
  module ClassMethods
    def current_scope
      scope, exclusive = Thread.current[:mongo_model_scope]
      current = if exclusive
        scope
      elsif scope
        default_scope ? default_scope.merge(scope) : scope
      else
        default_scope
      end
    end

    def with_exclusive_scope *args, &block
      with_scope *(args << true), &block
    end

    def with_scope *args, &block
      if args.last.is_a?(TrueClass) or args.last.is_a?(FalseClass)
        exclusive = args.pop
      else
        exclusive = false
      end

      scope = query *args
      previous_scope, previous_exclusive = Thread.current[:mongo_model_scope]
      raise "exclusive scope already applied!" if previous_exclusive

      begin
        scope = previous_scope.merge scope if !exclusive and previous_scope
        Thread.current[:mongo_model_scope] = [scope, exclusive]
        return block.call
      ensure
        Thread.current[:mongo_model_scope] = [previous_scope, false]
      end
    end

    inheritable_accessor :_default_scope, nil
    def default_scope *args, &block
      if block
        self._default_scope = -> {query block.call}
      elsif !args.empty?
        self._default_scope = -> {query *args}
      else
        _default_scope && _default_scope.call
      end
    end

    def scope name, *args, &block
      model = self
      metaclass.define_method name do
        query (block && instance_eval(&block)) || args
      end
    end


    #
    # finders
    #
    def count selector = {}, options = {}
      if current = current_scope
        super current.selector.merge(selector), current.options.merge(options)
      else
        super selector, options
      end
    end

    def first  selector = {}, options = {}
      if current = current_scope
        super current.selector.merge(selector), current.options.merge(options)
      else
        super selector, options
      end
    end

    def each  selector = {}, options = {}, &block
      if current = current_scope
        super current.selector.merge(selector), current.options.merge(options), &block
      else
        super selector, options, &block
      end
    end
  end
end