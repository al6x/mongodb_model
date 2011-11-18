require 'spec_helper'

describe 'CRUD Callbacks' do
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
  after{remove_constants :MainObject}

  before do
    @child = EmbeddedObject.new
    @object = MainObject.new
    @object.children = [@child]
  end

  it 'create' do
    %w(before_validate after_validate before_save before_create after_create after_save).each do |name|
      @object.should_receive(name).once.ordered.and_return(true)
      @child.should_receive(name).once.ordered.and_return(true)
    end

    db.objects.save(@object).should be_true
  end

  it 'update' do
    @object.dont_watch_callbacks do
      db.objects.save(@object).should be_true
    end

    %w(before_validate after_validate before_save before_update after_update after_save).each do |name|
      @object.should_receive(name).once.ordered.and_return(true)
      @child.should_receive(name).once.ordered.and_return(true)
    end
    db.objects.save(@object).should be_true
  end

  it 'delete' do
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

  it "should fire :after_build callback after building the object" do
    @object.dont_watch_callbacks do
      db.objects.save(@object).should be_true
    end

    MainObject.after_instantiate do |instance|
      instance.should_receive(:after_build)
    end
    EmbeddedObject.after_instantiate do |instance|
      instance.should_receive(:after_build)
    end
    db.objects.first
  end
end