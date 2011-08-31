class Mongo::Model::Query < Object
  attr_reader :model, :selector, :options

  def initialize model, selector = {}, options = {} *args
    @model, @selector, @options = model, selector, options
  end

  def class
    ::Mongo::Model::Query
  end

  def merge query
    raise "can't merge queries with different models!" unless model == query.model
    self.class.new model, selector.merge(query.selector), options.merge(query.options)
  end

  def inspect
    "#<Mongo::Model::Query: #{model} #{@selector.inspect} #{@options.inspect}>"
  end
  alias_method :to_s, :inspect

  def == o
    self.class == o.class and ([model, selector, options] == [o.model, o.selector, o.options])
  end

  def build attributes = {}, options = {}
    model.build selector.merge(attributes), options
  end

  def create attributes = {}, options = {}
    model.create selector.merge(attributes), options
  end

  def create! attributes = {}, options = {}
    model.create! selector.merge(attributes), options
  end

  protected
    def method_missing method, *args, &block
      model.with_scope selector, options do
        result = model.send method, *args, &block
        result = self.merge result if result.is_a? self.class
        result
      end
    end
end