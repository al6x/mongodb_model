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
    def build attributes = {}, options = {}, &block
      model = self.new
      model.set attributes, options
      block.call model if block
      model
    end

    def create attributes = {}, options = {}, &block
      model = build attributes, options, &block
      model.save
      model
    end

    def create! attributes = {}, options = {}, &block
      model = build attributes, options, &block
      model.save || raise(Mongo::Error, "can't create #{attributes.inspect}!")
      model
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