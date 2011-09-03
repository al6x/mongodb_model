module Mongo::Model::Db
  module ClassMethods
    inheritable_accessor :_db, nil
    def db= v
      self._db = if v.is_a? ::Proc
        v
      elsif v.is_a? ::Symbol
        -> do
          db_name = ::Mongo::Model.resolve_db_alias v
          ::Mongo::Model.connection.db db_name
        end
      else
        -> {v}
      end
    end

    def db *args, &block
      if block
        self.db = block
      elsif !args.empty?
        args.size.must == 1
        self.db = args.first
      else
        (_db && _db.call) || ::Mongo::Model.db
      end
    end

    inheritable_accessor :_collection, nil
    def collection= v
      self._collection = if v.is_a? ::Proc
        v
      elsif v.is_a? ::Symbol
        -> {db.collection v}
      else
        -> {v}
      end
    end

    def collection *args, &block
      if block
        self.collection = block
      elsif !args.empty?
        args.size.must == 1
        self.collection = args.first
      else
        (_collection && _collection.call) || db.collection(default_collection_name)
      end
    end

    def default_collection_name
      first_ancestor_class = ancestors.find{|a| a.is_a? Class} ||
        raise("can't evaluate default collection name for #{self}!")
      first_ancestor_class.alias.pluralize.underscore.to_sym
    end
  end
end