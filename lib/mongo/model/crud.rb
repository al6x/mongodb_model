module Mongo::Model::Crud
  def save options = {}
    with_collection options do |collection, options|
      collection.save self, options
    end
  end

  def save! *args
    save(*args) || raise(Mongo::Error, "can't save invalid model (#{self.errors})!")
  end

  def delete options = {}
    with_collection options do |collection, options|
      collection.delete self, options
    end
  end

  def delete! *args
    delete(*args) || raise(Mongo::Error, "can't delete invalid model #{self.errors}!")
  end

  def update doc, options = {}
    self.class.collection.update({_id: _id}, doc, options)
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
      model.save || raise(Mongo::Error, "can't create #{self} #{model.errors.inspect}!")
      model
    end

    def delete_all selector = {}, options = {}
      success = true
      each(selector){|o| success = false unless o.delete options}
      success
    end

    def delete_all! selector = {}, options = {}
      delete_all(selector, options) || raise(Mongo::Error, "can't delete #{selector.inspect}!")
    end

    def update selector, doc, options = {}
      collection.update selector, doc, options
    end
  end

  protected
    def with_collection options, &block
      options = options.clone
      collection = options.delete(:collection) || self.class.collection
      block.call collection, options
    end
end