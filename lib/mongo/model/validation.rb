module Mongo::Model::Validation
  def errors
    @_errors ||= Validatable::Errors.new
  end

  def run_validations
    self.class.validations.each do |v|
      if v.respond_to?(:validate)
        v.validate self
      elsif v.is_a? Proc
        v.call self
      else
        send v
      end
    end
    true
  end

  module ClassMethods
    include ::Validatable::Macros

    inheritable_accessor :validations, []

    def validates_uniqueness_of *args
      add_validations(args, Mongo::Model::UniquenessValidator)
    end

    def validate validation
      validations << validation
    end

    protected
      def add_validations(args, klass)
        options = args.last.is_a?(Hash) ? args.pop : {}
        args.each do |attribute|
          new_validation = klass.new self, attribute, options
          validate new_validation
        end
      end
  end
end