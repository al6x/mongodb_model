module Mongo::Model::Crud
  def save options = {}
    with_collection options do |collection, options|
      collection.save self, options
    end
  end

  def save! *args
    save(*args) || raise(Mongo::Error, "can't save invalid model (#{self.errors})!")
  end

  def destroy options = {}
    with_collection options do |collection, options|
      collection.destroy self, options
    end
  end

  def destroy! *args
    destroy(*args) || raise(Mongo::Error, "can't destroy invalid model #{self.errors}!")
  end

  module ClassMethods
    def build attributes = {}, options = {}
      self.new.set attributes, options
    end

    def create attributes = {}, options = {}
      o = build attributes, options
      o.save
      o
    end

    def create! attributes = {}, options = {}
      o = create attributes
      raise(Mongo::Error, "can't create #{attributes.inspect}!") if o.new_record?
      o
    end

    def destroy_all selector = {}, options = {}
      success = true
      collection = options[:collection] || self.collection
      each(selector){|o| success = false unless o.destroy}
      success
    end

    def destroy_all! selector = {}, options = {}
      destroy_all(selector, options) || raise(Mongo::Error, "can't destroy #{selector.inspect}!")
    end
  end

  protected
    def with_collection options, &block
      options = options.clone
      collection = options.delete(:collection) || self.class.collection
      block.call collection, options
    end
end