require 'spec_helper'

describe "Attribute Convertors" do
  with_mongo_model

  after(:all){remove_constants :TheSample}

  convertors = Mongo::Model::AttributeConvertors::CONVERTORS

  it ":line convertor" do
    v = ['a', 'b']
    str_v = 'a, b'
    convertors[:line][:from_string].call(str_v).should == v
    convertors[:line][:to_string].call(v).should == str_v
  end

  it ":yaml convertor" do
    v = {'a' => 'b'}
    str_v = v.to_yaml.strip

    convertors[:yaml][:from_string].call(str_v).should == v
    convertors[:yaml][:to_string].call(v).should == str_v
  end

  it ":json convertor" do
    v = {'a' => 'b'}
    str_v = v.to_json.strip
    convertors[:json][:from_string].call(str_v).should == v
    convertors[:json][:to_string].call(v).should == str_v
  end

  it ":field should generate helper methods if :as_string option provided" do
    class ::TheSample
      inherit Mongo::Model

      attr_accessor :tags, :protected_tags
      available_as_string :tags, :line
      available_as_string :protected_tags, :line

      def initialize
        @tags, @protected_tags = [], []
      end

      assign do
        tags_as_string true
      end
    end

    o = TheSample.new

    # get
    o.tags_as_string.should == ''
    o.tags = %w(Java Ruby)
    o._clear_cache
    o.tags_as_string.should == 'Java, Ruby'

    # set
    o.tags_as_string = ''
    o.tags.should == []
    o.tags_as_string = 'Java, Ruby'
    o.tags.should == %w(Java Ruby)

    # mass assignment
    o.tags = []
    o.set tags_as_string: 'Java, Ruby'
    o.tags.should == %w(Java Ruby)

    # # protection
    o.protected_tags = []
    o.set protected_tags_as_string: 'Java, Ruby'
    o.protected_tags.should == []
  end
end