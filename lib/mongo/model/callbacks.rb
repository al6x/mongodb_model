module Mongo::Model::Callbacks
  inherit RubyExt::Callbacks

  module ClassMethods
    [:validate, :create, :update, :save, :destroy].each do |method_name|
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

    [:validate, :create, :update, :save, :destroy, :build].each do |method_name|
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