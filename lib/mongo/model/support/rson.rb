class Object
  def rson?
    false
  end
end

[
  Time,
  FalseClass,
  TrueClass,
  Numeric,
  Symbol,
  String,
  NilClass,
].each do |klass|
  klass.class_eval do
    def to_rson options = {}
      self
    end

    def rson?
      true
    end
  end
end

# [
#   String
# ].each do |klass|
#   klass.class_eval do
#     def to_rson options = {}
#       self.to_sym
#     end
#
#     def rson?
#       false
#     end
#   end
# end

Array.class_eval do
  def to_rson options = {}
    collect{|v| v.to_rson(options)}
  end

  def rson?
    all?{|v| v.rson?}
  end
end

[Hash, OpenObject].each do |klass|
  klass.class_eval do
    def to_rson options = {}
      r = self.class.new
      each do |k, v|
        r[k.to_sym] = v.to_rson(options)
      end
      r
    end

    def rson?
      each do |k, v|
        return false unless k.rson? and v.rson?
      end
      true
    end
  end
end