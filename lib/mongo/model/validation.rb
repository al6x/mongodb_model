module Mongo::Model::Validation
  def errors
    @_errors ||= Validatable::Errors.new
  end

  def run_validations
    self.class.validations.each{|v| v.validate self}
    true
  end

  module ClassMethods
    include ::Validatable::Macros

    inheritable_accessor :validations, []

    def validates_uniqueness_of *args
      add_validations(args, Mongo::Model::UniquenessValidator)
    end

    protected
      def add_validations(args, klass)
        options = args.last.is_a?(Hash) ? args.pop : {}
        args.each do |attribute|
          new_validation = klass.new self, attribute, options
          validations << new_validation
        end
      end
  end
end