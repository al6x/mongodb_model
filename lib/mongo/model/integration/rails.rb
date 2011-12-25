Validatable::Errors.class_eval do
  def full_messages
    collect do |attribute, messages|
      if attribute == :base
        messages
      else
        attribute = attribute.to_s.humanize
        messages.collect{|message| "#{attribute} #{message}"}
      end
    end.flatten
  end
end

module Mongo::Model::Rails
  def to_model; self end

  def persisted?; _saved end

  def to_key
    persisted? ? [id] : nil
  end

  def new_record?; new? end

  module ClassMethods
    def model_name
      @_model_name ||= begin
        namespace = self.ancestors.detect { |n| n.respond_to?(:_railtie) }
        ActiveModel::Name.new(self, namespace)
      end
    end
  end
end
Mongo::Model.inherit Mongo::Model::Rails