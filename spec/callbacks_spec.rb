require 'spec_helper'

describe 'Callbacks' do
  with_mongo_model

  after{remove_constants :Post, :Unit}

  it "should works in common use case" do
    class Unit
      inherit Mongo::Model

      before_validate :validate_unit
      after_save :unit_saved

      attr_accessor :items
      embedded :items

      class Item
        inherit Mongo::Model

        before_validate :validate_item
        after_save :item_saved
      end
    end

    item = Unit::Item.new
    unit = Unit.new
    unit.items = [item]

    unit.should_receive(:validate_unit).once.ordered.and_return(nil)
    unit.should_receive(:unit_saved).once.ordered.and_return(nil)
    item.should_receive(:validate_item).once.ordered.and_return(nil)
    item.should_receive(:item_saved).once.ordered.and_return(nil)

    db.units.save(unit).should be_true
  end

  warn 'duplicated spec'
  it "should fire special :build callback after building object" do
    class Post
      inherit Mongo::Model
      collection :posts

      class Tags < Array
      end

      def tags
        @tags ||= Tags.new
      end
      attr_writer :tags

      after_build do |post|
        post.tags = Tags.new.replace post.tags
      end
    end

    post = Post.new
    post.save!

    Post.first.tags.class.should == Post::Tags
  end
end