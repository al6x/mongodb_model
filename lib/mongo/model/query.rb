class Mongo::Model::Query < Object
  attr_reader :model_class, :selector, :options

  def initialize model_class, selector = {}, options = {}
    @model_class, @selector, @options = model_class, selector, options
  end

  def class
    ::Mongo::Model::Query
  end

  def merge query
    model_class == query.model_class or
      model_class.is?(query.model_class) or
      query.model_class.is?(model_class) or
      raise("can't merge queries with different models!")

    self.class.new model_class, selector.merge(query.selector), options.merge(query.options)
  end

  def inspect
    "#<Mongo::Model::Query: #{model_class} #{@selector.inspect} #{@options.inspect}>"
  end
  alias_method :to_s, :inspect

  def == o
    self.class == o.class and ([model_class, selector, options] == [o.model_class, o.selector, o.options])
  end

  def build attributes = {}, options = {}
    model_class.build attributes, options do |model|
      model.set! selector
    end
  end

  def create attributes = {}, options = {}
    model_class.create attributes, options do |model|
      model.set! selector
    end
  end

  def create! attributes = {}, options = {}
    model_class.create! attributes, options do |model|
      model.set! selector
    end
  end

  protected

    def method_missing method, *args, &block
      model_class.with_scope selector, options do
        result = model_class.send method, *args, &block
        result = self.merge result if result.is_a? self.class
        result
      end
    end
end