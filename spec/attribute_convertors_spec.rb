require 'spec_helper'

describe "Attribute convertors" do
  with_mongo_model

  after(:all){remove_constants :TheSample}

  convertors = Mongo::Model::AttributeConvertors::CONVERTORS

  it "should convert line of comma-separated tokens to array and backward" do
    v = ['a', 'b']
    str_v = 'a, b'
    convertors[:line][:from_string].call(str_v).should == v
    convertors[:line][:to_string].call(v).should == str_v
  end

  it "should convert to YAML and backward" do
    v = {'a' => 'b'}
    str_v = v.to_yaml.strip

    convertors[:yaml][:from_string].call(str_v).should == v
    convertors[:yaml][:to_string].call(v).should == str_v
  end

  it "should convert to JSON and backward" do
    v = {'a' => 'b'}
    str_v = v.to_json.strip
    convertors[:json][:from_string].call(str_v).should == v
    convertors[:json][:to_string].call(v).should == str_v
  end

  it "should generate helper methods if :as_string option provided" do
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

    # Get.
    o.tags_as_string.should == ''
    o.tags = %w(Java Ruby)
    o._cache.clear
    o.tags_as_string.should == 'Java, Ruby'

    # Set.
    o.tags_as_string = ''
    o.tags.should == []
    o.tags_as_string = 'Java, Ruby'
    o.tags.should == %w(Java Ruby)

    # Mass assignment.
    o.tags = []
    o.set tags_as_string: 'Java, Ruby'
    o.tags.should == %w(Java Ruby)

    # Protection.
    o.protected_tags = []
    o.set protected_tags_as_string: 'Java, Ruby'
    o.protected_tags = []
  end
end