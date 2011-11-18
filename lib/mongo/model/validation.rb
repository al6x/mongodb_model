module Mongo::Model::Validation
  def valid? options = {}
    errors.clear
    run_validations options
  end
  def invalid?(options = {}); !valid?(options) end

  protected
    def run_validations options = {}
      with_model_callbacks [:validate], options, [self] do
        # Validating main model.
        self.run_validations_for_this_model_only
        result = errors.empty?

        # Validating embedded models.
        embedded_models.reduce result do |result, model|
          result &= model.valid?(options)
        end
      end
    end
end