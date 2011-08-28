module Mongo::Model::Callbacks
  inherit RubyExt::Callbacks

  def _run_callbacks type, method_name
    if type == :before
      run_before_callbacks method_name, method: method_name
    elsif type == :after
      run_after_callbacks method_name, method: method_name
    else
      raise "invalid callback type (#{type})!"
    end
  end

  module ClassMethods
    [:validate, :update, :save, :destroy].each do |method_name|
      define_method "before_#{method_name}" do |*args, &block|
        opt = args.extract_options!
        if block
          set_callback method_name, :before, opt, &block
        else
          opt[:terminator] = false unless opt.include? :terminator
          args.each{|executor| set_callback method_name, :before, executor, opt}
        end
      end

      define_method "after_#{method_name}" do |*args, &block|
        opt = args.extract_options!
        if block
          set_callback method_name, :after, opt, &block
        else
          args.each{|executor| set_callback method_name, :after, executor, opt}
        end
      end
    end
  end
end