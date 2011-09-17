require 'test/unit'
require 'active_model'

require 'mongo/model'
require 'mongo/model/integration/rails'

class LintTest < ActiveModel::TestCase
  include ActiveModel::Lint::Tests

  class TheModel
    inherit Mongo::Model
  end

  def setup
    @model = TheModel.new
  end
end