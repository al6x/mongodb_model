class Mongo::Model::UniquenessValidator < Validatable::ValidationBase
  attr_accessor :scope, :case_sensitive

  def initialize(klass, attribute, options={})
    super
    self.case_sensitive = false if case_sensitive == nil
  end

  def valid?(instance)
    conditions = {}

    conditions[scope] = instance.send scope if scope

    value = instance.send attribute
    if case_sensitive
      conditions[attribute] = value
    else
      conditions[attribute] = /^#{Regexp.escape(value.to_s)}$/i
    end

    # Make sure we're not including the current document in the query
    conditions[:_id] = {_ne: instance._id} if instance._id

    !klass.exists?(conditions)
  end

  def message(instance)
    super || "#{attribute} must be unique!"
  end
end