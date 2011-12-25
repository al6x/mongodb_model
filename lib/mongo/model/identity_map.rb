module Mongo::Model::IdentityMap
  inherited do
    Mongo::Model::IdentityMap.models.add self
  end

  def original
    unless _cache[:original_cached]
      _cache[:original_cached] = true
      _cache[:original] = id && self.class.get_from_identity_map(id)
    end
    _cache[:original]
  end

  module ClassMethods
    def identity_map
      @identity_map ||= {}
    end

    def get_from_identity_map id
      doc = identity_map[id]
      from_mongo doc if doc
    end

    def from_mongo doc
      model = super doc
      model.class.identity_map[model.id] = doc if model.id
      model
    end
  end

  class << self
    def models
      @models ||= Set.new
    end

    def clear; models.collect(&:identity_map).every.clear end
  end
end