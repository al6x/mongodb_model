require 'mongodb_model/gems'

require 'validatable'
require 'file_model'
require 'ruby_ext'
require 'mongo/object'

module Mongo::Model; end

%w(
  support/types

  db
  conversion
  assignment
  callbacks
  validation
  validation/uniqueness_validator
  crud
  query
  query_mixin
  scope
  attribute_convertors
  file_model
  misc
  model
).each{|f| require "mongo/model/#{f}"}

module Mongo
  module Model
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
      Mongo::Model::FileModel,
      Misc
  end
end

Mongo.defaults.merge! \
  convert_underscore_to_dollar: true,
  batch_size:                   50,
  multi:                        true,
  safe:                         true

require 'mongo/model/integration/rails' if defined? Rails