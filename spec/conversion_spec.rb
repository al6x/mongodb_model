require 'spec_helper'

describe 'Model callbacks' do
  with_mongo_model

  before :all do
    class BasePost
      inherit Mongo::Model

      attr_accessor :text, :token

      attr_writer :comments
      def comments; @comments ||= [] end

      def teaser
        @text && @text[0..10]
      end
    end

    class BaseComment
      inherit Mongo::Model

      attr_accessor :text
    end
  end

  before do
    class Post < BasePost; end
    class Comment < BaseComment; end
  end

  after{remove_constants :Post, :Comment}
  after(:all){remove_constants :BasePost, :BaseComment}

  def build_post_with_comment
    post = Post.new text: 'StarCraft releasing soon!', token: 'secret'
    post.comments << Comment.new(text: 'Cool!')
    post
  end

  it "should work without arguments" do
    post = build_post_with_comment
    post.to_rson.should == {
      'text' => 'StarCraft releasing soon!',
      'token' => 'secret',
      'comments' => [
        {'text' => 'Cool!'}
      ]
    }
  end

  it "only, except, methods" do
    post = build_post_with_comment
    post.to_rson(only: :text).should == {'text' => 'StarCraft releasing soon!'}
    post.to_rson(except: :token).should == {
      'text' => 'StarCraft releasing soon!',
      'comments' => [
        {'text' => 'Cool!'}
      ]
    }
    post.to_rson(only: [], methods: :teaser).should == {'teaser' => 'StarCraft r'}
  end

  it "profiles" do
    Post.class_eval do
      profile :public, only: [:text, :comments], methods: :teaser
    end

    post = build_post_with_comment

    -> {post.to_rson(profile: :public)}.should raise_error(/profile :public not defined for Comment/)

    Comment.class_eval do
      profile :public
    end

    post.to_rson(profile: :public).should == {
      'text' => 'StarCraft releasing soon!',
      'teaser' => 'StarCraft r',
      'comments' => [
        {'text' => 'Cool!'}
      ]
    }
  end
  
  it "should include errors" do
    Post.class_eval do
      validates_presence_of :token
    end

    post = Post.new text: 'StarCraft releasing soon!'
    post.valid?.should be_false
    
    post.to_rson.should == {
      'text' => 'StarCraft releasing soon!',
      'errors' => {"token" => ["can't be empty"]}
    }
    
    post.to_rson(errors: false).should == {
      'text' => 'StarCraft releasing soon!'
    }
  end

  it "to_json" do
    post = build_post_with_comment
    rson = mock
    rson.should_receive(:to_json).and_return(:ok)
    post.should_receive(:to_rson).with(only: :text).and_return(rson)
    post.to_json(only: :text).should == :ok
  end

  it "to_xml" do
    post = build_post_with_comment
    rson = mock
    rson.should_receive(:to_xml).and_return(:ok)
    post.should_receive(:to_rson).with(only: :text).and_return(rson)
    post.to_xml(only: :text).should == :ok
  end
end