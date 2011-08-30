#
# Boolean
#
module Mongo::Model::BooleanType
  Mapping = {
    true    => true,
    'true'  => true,
    'TRUE'  => true,
    'True'  => true,
    't'     => true,
    'T'     => true,
    '1'     => true,
    1       => true,
    1.0     => true,
    false   => false,
    'false' => false,
    'FALSE' => false,
    'False' => false,
    'f'     => false,
    'F'     => false,
    '0'     => false,
    0       => false,
    0.0     => false,
    nil     => nil
  }

  def cast value
    if value.is_a? Boolean
      value
    else
      Mapping[value] || false
    end
  end
end

class Boolean; end unless defined?(Boolean)

Boolean.extend Mongo::Model::BooleanType


#
# Date
#
require 'date'
Date.class_eval do
  def self.cast value
    if value.nil? || value == ''
      nil
    else
      date = value.is_a?(::Date) || value.is_a?(::Time) ? value : ::Date.parse(value.to_s)
      date.to_date
    end
  rescue
    nil
  end
end


#
# Float
#
Float.class_eval do
  def self.cast value
    value.nil? ? nil : value.to_f
  end
end


#
# Integer
#
Integer.class_eval do
  def self.cast value
    value_to_i = value.to_i
    if value_to_i == 0 && value != value_to_i
      value.to_s =~ /^(0x|0b)?0+/ ? 0 : nil
    else
      value_to_i
    end
  end
end


#
# String
#
String.class_eval do
  def self.cast value
    value.nil? ? nil : value.to_s
  end
end


#
# Time
#
Time.class_eval do
  def self.cast value
    if value.nil? || value == ''
      nil
    else
      # time_class = ::Time.try(:zone).present? ? ::Time.zone : ::Time
      # time = value.is_a?(::Time) ? value : time_class.parse(value.to_s)
      # strip milliseconds as Ruby does micro and bson does milli and rounding rounded wrong
      # at(time.to_i).utc if time

      value.is_a?(::Time) ? value : Date.parse(value.to_s).to_time
    end
  end
end