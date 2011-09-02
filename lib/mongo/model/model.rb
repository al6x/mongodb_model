module Mongo::Model
  include Mongo::Object

  attr_accessor :_id, :_class

  def _id?; !!_id end
  def new_record?; !_id end

  inherited do
    alias_method :eql?, :model_eql?
    alias_method :==, :model_eq?
  end

  def model_eql? o
    return true if equal? o
    self.class == o.class and self == o
  end

  def model_eq? o
    return true if equal? o

    variables = {}; ::Mongo::Object.each_object_instance_variable(self){|n, v| variables[n] = v}
    o_variables = {}; ::Mongo::Object.each_object_instance_variable(o){|n, v| o_variables[n] = v}
    variables == o_variables
  end

  class << self
    attr_accessor :db, :connection
    attr_required :db, :connection
  end
end