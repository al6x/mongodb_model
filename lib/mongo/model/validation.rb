module Mongo::Model::Validation
  def valid? options = {}
    errors.clear
    run_validations options
  end
  def invalid?(options = {}); !valid?(options) end

  # Catching erros during CRUD and adding it to errors, like unique index.

  def create_object *args
    with_exceptions_as_errors do
      super
    end
  end

  def update_object *args
    with_exceptions_as_errors do
      super
    end
  end

  def delete_object *args
    with_exceptions_as_errors do
      super
    end
  end

  protected
    def with_exceptions_as_errors &block
      block.call
    rescue Mongo::OperationFailure => e
      if [11000, 11001].include? e.error_code
        errors.add :base, "not unique value!"
        false
      else
        raise e
      end
    end

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