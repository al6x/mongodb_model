require 'mongo_model/gems'

require 'validatable'
require 'file_model'
require 'i18n'
require 'ruby_ext'
require 'mongo/object'

module Mongo::Model; end

%w(
  support/types

  db
  assignment
  callbacks
  validation
  validation/uniqueness_validator
  crud
  query
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
      Assignment,
      Callbacks,
      Validation,
      Crud,
      Query,
      Scope,
      AttributeConvertors,
      Mongo::Model::FileModel,
      Misc
  end
end

Mongo.defaults.merge! \
  symbolize:                    true,
  convert_underscore_to_dollar: true,
  batch_size:                   50,
  multi:                        true,
  safe:                         true