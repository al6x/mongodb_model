module Mongo::Model::Crud
  # Enhancing Mongo::Object CRUD.

  def create_object collection, options
    with_model_crud_callbacks [:save, :create], options do |mongo_options|
      super collection, mongo_options
      true
    end
  end

  def update_object collection, options
    with_model_crud_callbacks [:save, :update], options do |mongo_options|
      super collection, mongo_options
      true
    end
  end

  def delete_object collection, options
    with_model_crud_callbacks [:delete], options do |mongo_options|
      super collection, mongo_options
      true
    end
  end

  # Model CRUD.

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
    with_collection options do |collection, options|
      collection.update({_id: _id}, doc, options)
    end
  end

  protected
    def with_model_crud_callbacks methods, options, &block
      models = [self] + embedded_models(true)

      return false if (options[:validate] != false) and invalid?(options)

      with_model_callbacks methods, options, models do
        mongo_options = options.clone
        mongo_options.delete :validate
        mongo_options.delete :callbacks

        block.call mongo_options
      end
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