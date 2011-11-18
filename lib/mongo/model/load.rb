require 'mongo/object'
require 'ruby_ext'

module Mongo::Model; end

%w(
  support

  db
  conversion
  assignment
  callbacks
  validation
  crud
  query
  query_mixin
  scope
  attribute_convertors
  misc
  model
).each{|f| require "mongo/model/#{f}"}

module Mongo
  module Model
    autoload :FileModel, 'mongo/model/integration/file_model'

    inherit \
      Db,
      Conversion,
      Assignment,
      Callbacks,
      Validation,
      Crud,
      QueryMixin,
      Scope,
      AttributeConvertors,
      Misc
  end
end

Mongo.defaults.merge! \
  convert_underscore_to_dollar: true,
  batch_size:                   50,
  multi:                        true,
  safe:                         true,
  generate_id:                  true

# Integration with Rails.
unless $dont_use_rails
  require 'mongo/model/integration/rails' if defined? Rails
end

# Integration with Validatable2
unless $dont_use_validatable
  require 'validatable'
  require 'mongo/model/integration/validatable'
  require 'mongo/model/integration/validatable/uniqueness_validator'
  Mongo::Model.inherit Validatable::Model
end