require 'ruby_ext'

module Mongo::Model; end

%w(
  db
  conversion
  assignment
  callbacks
  crud
  validation
  query
  query_mixin
  scope
  attribute_convertors
  misc
  model
).each{|f| require "mongo/model/#{f}"}

# Assembling model.
module Mongo
  module Model
    autoload :IdentityMap, 'mongo/model/identity_map'

    inherit \
      Db,
      Conversion,
      Assignment,
      Callbacks,
      Crud,
      Validation,
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

# Integrations.

unless $dont_use_rails
  require 'mongo/model/integration/rails' if defined? Rails
end

unless $dont_use_validatable
  require 'validatable'
  require 'mongo/model/integration/validatable'
  require 'mongo/model/integration/validatable/uniqueness_validator'
  Mongo::Model.inherit Validatable::Model
end

unless $dont_use_file_model
  Mongo::Model.autoload :FileModel, 'mongo/model/integration/file_model'
end