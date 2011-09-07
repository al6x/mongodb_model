module Mongo::Model::Db
  module ClassMethods
    inheritable_accessor :db_name, :default
    def db name = nil
      if name
        self.db_name = name
      else
        Mongo.db db_name
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
        first_ancestor_class.alias.pluralize.underscore.to_sym
      end
  end
end