require 'file_model'

module Mongo::Model::FileModel
  inherit ::FileModel::Helper

  def attribute_get name
    instance_variable_get :"@#{name}"
  end

  def attribute_set name, value
    instance_variable_set :"@#{name}", value
  end

  module ClassMethods
    def mount_file attr_name, file_model_class
      super

      before_validate do |model|
        file_model = model.send(attr_name)
        file_model.run_validations
        model.errors[attr_name] = file_model.errors unless file_model.errors.empty?
      end

      after_save{|model| model.send(attr_name).save!}

      after_destroy{|model| model.send(attr_name).destroy!}
    end
  end
end