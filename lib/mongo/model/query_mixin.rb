module Mongo::Model::QueryMixin
  def exists? options = {}
    self.class.count({id: id}, options) > 0
  end
  alias_method :exist?, :exists?

  module ClassMethods
    include Mongo::DynamicFinders

    def count selector = {}, options = {}
      collection.count selector, options
    end

    def size *args
      count *args
    end

    def first selector = {}, options = {}
      collection.first selector, options
    end

    def each selector = {}, options = {}, &block
      collection.each selector, options, &block
    end

    def all selector = {}, options = {}, &block
      if block
        each selector, options, &block
      else
        list = []
        each(selector, options){|doc| list << doc}
        list
      end
    end

    def first! selector = {}, options = {}
      first(selector, options) || raise(Mongo::NotFound, "document with selector #{selector} not found!")
    end

    def exists? selector = {}, options = {}
      count(selector, options) > 0
    end
    alias_method :exist?, :exists?

    def query *args
      if args.first.is_a? Mongo::Model::Query
        args.first
      else
        selector, options = args.first.is_a?(::Array) ? args.first : args
        Mongo::Model::Query.new self, (selector || {}), (options || {})
      end
    end
    alias_method :where, :query
  end
end