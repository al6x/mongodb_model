module Mongo::Model::Callbacks
  inherit RubyExt::Callbacks

  protected
    def with_model_callbacks methods, options, models, &block
      # Firing before callbacks.
      unless options[:callbacks] == false
        methods.each do |method|
          models.each do |model|
            return false unless model.run_before_callbacks method, method
          end
        end
      end

      result = block.call

      # Firing after callbacks.
      unless options[:callbacks] == false
        methods.reverse.each do |method|
          models.each do |model|
            model.run_after_callbacks method, method
          end
        end
      end

      result
    end

  module ClassMethods
    [:validate, :create, :update, :save, :delete].each do |method_name|
      define_method "before_#{method_name}" do |*args, &block|
        opt = args.extract_options!
        if block
          set_callback method_name, :before, opt, &block
        else
          opt[:terminator] = false unless opt.include? :terminator
          args.each{|executor| set_callback method_name, :before, executor, opt}
        end
      end
    end

    [:validate, :create, :update, :save, :delete, :build].each do |method_name|
      define_method "after_#{method_name}" do |*args, &block|
        opt = args.extract_options!
        if block
          set_callback method_name, :after, opt, &block
        else
          args.each{|executor| set_callback method_name, :after, executor, opt}
        end
      end
    end

    alias_method :before_validation, :before_validate
    alias_method :after_validation, :after_validate
  end
end