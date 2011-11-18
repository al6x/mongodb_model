module Validatable::Model
  def errors
    @_errors ||= Validatable::Errors.new
  end

  protected
    def run_validations_for_this_model_only
      self.class.validations.each do |v|
        if v.respond_to?(:validate)
          v.validate self
        elsif v.is_a? Proc
          v.call self
        else
          send v
        end
      end
    end

  module ClassMethods
    include ::Validatable::Macros

    inheritable_accessor :validations, []

    def validates_uniqueness_of *args
      add_validations(args, ::Validatable::UniquenessValidator)
    end

    def validate validation = nil, &block
      validations.push block || validation
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