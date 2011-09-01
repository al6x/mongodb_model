module Mongo::Model::Misc
  def update_timestamps
    now = Time.now.utc
    self.created_at ||= now
    self.updated_at = now
  end


  def _cache
    @_cache ||= {}
  end
  # def _clear_cache
  #   @_cache = {}
  # end

  def dom_id
    # new_record? ? "new_#{self.class.name.underscore}" : to_param
    to_param
  end

  def to_param
    (_id || '').to_s
  end

  delegate :t, to: I18n

  def reload
    obj = self.class.by_id!(_id || raise("can't reload new document (#{self})!"))
    instance_variables.each{|n| remove_instance_variable n}
    obj.instance_variables.each do |n|
      instance_variable_set n, obj.instance_variable_get(n)
    end
    nil
  end

  def original
    @_original ||= _id? ? self.class.by_id(self._id) : nil
  end

  module ClassMethods
    delegate :t, to: I18n

    def timestamps!
      attr_accessor :created_at, :updated_at
      before_save :update_timestamps
    end
  end
end