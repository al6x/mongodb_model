module Mongo::Model::Db
  module ClassMethods
    inheritable_accessor :db_name, nil
    def db name = nil
      if name
        self.db_name = name
      else
        Mongo.db db_name || Mongo::Model.default_database_name
      end
    end

    inheritable_accessor :collection_name, nil
    def collection name = nil, &block
      if name
        self.collection_name = name
      else
        db.collection(collection_name || default_collection_name)
      end
    end

    protected
      def default_collection_name
        first_ancestor_class = ancestors.find{|a| a.is_a? Class} ||
          raise("can't evaluate default collection name for #{self}!")
        als = first_ancestor_class.alias

        unless als.respond_to? :pluralize
          warn <<-TEXT
WARN: It seems that there's no `String.pluralize` method, Mongo::Model needs it to automatically infer
collection name from the model class name.
Please specify collection name explicitly (like `collection :users`) or provide the `String.pluralize`
method.
TEXT
          raise "collection name for #{first_ancestor_class} not defined (add it, like `collection :users`)!"
        end

        als.pluralize.underscore.to_sym
      end
  end
end

Mongo::Model.class_eval do
  class << self
    attr_accessor :default_database_name

    def default_database
      Mongo.db default_database_name
    end
  end
  self.default_database_name = :default
end