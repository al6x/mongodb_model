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


  module ClassMethods
    delegate :t, to: I18n

    def timestamps!
      attr_accessor :created_at, :updated_at
      before_save :update_timestamps
    end
  end
end