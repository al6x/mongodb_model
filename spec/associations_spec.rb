require 'spec_helper'

describe 'Associations' do
  with_mongo_model

  after{remove_constants :Post, :Comment}

  it "basic" do
    class Post
      inherit Mongo::Model
      collection :posts

      attr_accessor :text

      def comments
        Comment.query({post_id: _id}, {sort: [[:created_at, -1]]})
      end
    end

    class Comment
      inherit Mongo::Model
      collection :comments

      attr_accessor :text, :post_id

      def == o
        [self.class, text, post_id] == [o.class, o.text, o.post_id]
      end

      timestamps!
    end

    post1 = Post.create! text: 'Post 1'
    comment1 = post1.comments.create! text: 'Comment 1'
    comment2 = post1.comments.create! text: 'Comment 2'

    post2 = Post.create! text: 'Post 2'
    comment3 = post2.comments.create! text: 'Comment 3'

    post1.comments.count.should == 2
    post1.comments.all.should == [comment2, comment1]
  end
end