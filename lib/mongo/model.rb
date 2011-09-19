require 'mongodb_model/gems'

require 'validatable'
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
  misc
  model
).each{|f| require "mongo/model/#{f}"}

module Mongo
  module Model
    autoload :FileModel, 'mongo/model/file_model'

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
  safe:                         true

require 'mongo/model/integration/rails' if defined? Rails