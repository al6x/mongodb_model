require 'spec_helper'

describe 'Callbacks' do
  with_mongo_model

  describe "basics" do
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
  end

  describe 'CRUD' do
    with_mongo_model

    before do
      class MainObject
        inherit Mongo::Model, RSpec::CallbackHelper

        attr_accessor :children
        embedded :children
      end

      class EmbeddedObject
        inherit Mongo::Model, RSpec::CallbackHelper
      end
    end
    after{remove_constants :MainObject, :Post}

    before do
      @child = EmbeddedObject.new
      @object = MainObject.new
      @object.children = [@child]
    end

    it 'should fire create callbacks' do
      %w(before_validate after_validate before_save before_create after_create after_save).each do |name|
        @object.should_receive(name).once.ordered.and_return(true)
        @child.should_receive(name).once.ordered.and_return(true)
      end

      db.objects.save(@object).should be_true
    end

    it 'should fire update callbacks' do
      @object.dont_watch_callbacks do
        db.objects.save(@object).should be_true
      end

      %w(before_validate after_validate before_save before_update after_update after_save).each do |name|
        @object.should_receive(name).once.ordered.and_return(true)
        @child.should_receive(name).once.ordered.and_return(true)
      end
      db.objects.save(@object).should be_true
    end

    it 'should fire delete callbacks' do
      @object.dont_watch_callbacks do
        db.objects.save(@object).should be_true
      end

      %w(before_validate after_validate before_delete after_delete).each do |name|
        @object.should_receive(name).once.ordered.and_return(true)
        @child.should_receive(name).once.ordered.and_return(true)
      end
      db.objects.delete(@object).should be_true
    end

    it 'should be able skip callbacks' do
      %w(before_validate after_validate before_save before_update after_update after_save).each do |name|
        @object.should_not_receive(name)
        @child.should_not_receive(name)
      end

      db.objects.save(@object, callbacks: false).should be_true
      db.objects.count.should == 1
      db.objects.save(@object, callbacks: false).should be_true
      db.objects.count.should == 1
      db.objects.delete(@object, callbacks: false).should be_true
      db.objects.count.should == 0
    end

    it 'should be able interrupt CRUD' do
      %w(before_validate after_validate before_save).each do |name|
        @object.should_receive(name).and_return true
        @child.should_receive(name).and_return true
      end

      @object.should_receive(:before_create).and_return true
      @child.should_receive(:before_create).and_return false

      db.objects.save(@object).should be_false
      db.objects.count.should == 0
    end

    # Rejected.
    # describe "embedded" do
    #   it 'should fire :delete on detached objects' do
    #     db.objects.save(@object).should be_true
    #     @object.children.clear
    #     @child.should_receive(:before_delete).once.and_return(true)
    #     db.objects.delete(@object).should be_true
    #   end
    #
    #   it 'should fire :delete on deleted objects in update' do
    #     db.objects.save(@object).should be_true
    #     @object.children.clear
    #     @child.should_receive(:before_delete).once.and_return(true)
    #     db.objects.save(@object).should be_true
    #   end
    #
    #   it 'should fire :create on new objects in update' do
    #     db.objects.save(@object).should be_true
    #     child2 = EmbeddedObject.new
    #     @object.children << child2
    #     child2.should_receive(:before_create).once.and_return(true)
    #     child2.should_not_receive(:before_update)
    #     db.objects.save(@object).should be_true
    #   end
    # end

    it "should fire after build callback after building the model" do
      @object.dont_watch_callbacks do
        db.objects.save(@object).should be_true
      end

      MainObject.after_instantiate do |instance|
        instance.should_receive(:after_build)
      end
      EmbeddedObject.after_instantiate do |instance|
        instance.should_not_receive(:after_build)
      end
      db.objects.first
    end

    it "should allow to use after build callback to post-process and alter model" do
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
end