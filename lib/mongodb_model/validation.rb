module Mongo::Model::Validation
  def _valid?
    !(respond_to?(:errors) and errors and !errors.empty?)
  end
end