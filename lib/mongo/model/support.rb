Array.class_eval do
  alias_method :each_value, :each
  alias_method :collect_with_value, :collect
end

Hash.class_eval do
  def collect_with_value &block
    {}.tap{|h| self.each{|k, v| h[k] = block.call v}}
  end
end

