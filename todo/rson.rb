module Mongoid::RadMiscellaneous
  extend ActiveSupport::Concern

  def to_rson options = {}
    with_errors = if options.include?('errors')
      options.delete 'errors'
    elsif options.include?(:errors)
      options.delete :errors
    else
      true
    end

    # standard MongoMaper as_json conversion
    hash = as_json(options)

    # MongoMaper fix
    hash['id'] = hash.delete('_id').to_s if hash.include? '_id'

    # adding errors
    if with_errors
      errors = {}
      errors.each do |name, list|
        errors[name.to_s] = list
      end
      hash['errors'] = errors unless errors.empty?
    end

    hash
  end
end