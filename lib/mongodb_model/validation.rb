module Mongo::Model::Validation
  inherit Validatable

  alias_method :_valid?, :valid?

  module ClassMethods
    def validates_uniqueness_of(*args)
      add_validations(args, Mongo::Model::UniquenessValidator)
    end
  end
end