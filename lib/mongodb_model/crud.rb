module Mongo::Model::Crud
  def save opts = {}
    with_collection opts do |collection, opts|
      collection.save self, opts
    end
  end

  def save! *args
    save(*args) || raise(Mongo::Error, "can't save #{self.inspect}!")
  end

  def destroy opts = {}
    with_collection opts do |collection, opts|
      collection.destroy self, opts
    end
  end

  def destroy! *args
    destroy(*args) || raise(Mongo::Error, "can't destroy #{self.inspect}!")
  end

  module ClassMethods
    def build attributes, opts = {}
      self.new.set attributes, opts
    end

    def create attributes, opts = {}
      o = build attributes, opts
      o.save
      o
    end

    def create! attributes, opts = {}
      o = create attributes
      raise(Mongo::Error, "can't create #{attributes.inspect}!") if o.new_record?
      o
    end

    def destroy_all selector = {}, opts = {}
      success = true
      collection = opts[:collection] || self.collection
      each(selector){|o| success = false unless o.destroy}
      success
    end

    def destroy_all! selector = {}, opts = {}
      destroy_all(selector, opts) || raise(Mongo::Error, "can't destroy #{selector.inspect}!")
    end
  end

  protected
    def with_collection opts, &block
      opts = opts.clone
      collection = opts.delete(:collection) || self.class.collection
      block.call collection, opts
    end
end