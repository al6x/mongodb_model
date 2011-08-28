module Mongo::Model
  attr_accessor :_id, :_class

  def _id?; !!_id end
  def new_record?; !_id end

  class << self
    attr_accessor :db, :connection
    attr_required :db, :connection
  end
end