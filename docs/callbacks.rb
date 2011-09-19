# Callbacks in [Mongo Model][mongodb_model].
#
# Callbacks are handy way to execute custom logic at special
# moments of the lifecycle of the model. There are following
# callbacks available:
#
#     before_validate
#     after_validate
#
#     before_save
#     after_save
#
#     before_create
#     after_create
#
#     before_update
#     after_update
#
#     before_destroy
#     after_destroy
#
#     after_build
#
# All these callbacks also available on embedded models.
#
# In this example we create post with embedded comments and
# generate teasers on it using callbacks.
require 'mongo/model'

# Connecting to test database and cleaning it before starting.
Mongo::Model.default_database_name = :default_test
Mongo::Model.default_database.clear

# ### Basics

# Defining post, its teaser will be generated before saving.
class Post
  inherit Mongo::Model
  collection :posts

  attr_accessor :text, :teaser

  protected
    # Using `before_save` callback to generate teaser before saving the post
    # (You can also use block version instead of method).
    def generate_teaser
      @teaser = text[0..4] if text
    end
    before_save :generate_teaser
end

# Creating post, teaser will be generated when we save the post.
post = Post.new text: 'Norad II crashed!'
post.save!
p post.teaser                                     # => Norad

# ### Embedded Models
#
# Callbacks on children works the same way whith the only difference -
# when child removed from main object - child get `:destroy` and main object
# `:update` callbacks, details:
#
# - when main object created/updated/destroyed - the same callbacks propagated to
# its children.
# - when child added to existing main object - the main object and all its existing
# children get `:update` callback, but all newly created children get `:create` callback.
# - when child removed from existing main object - the main object and all its existing
# children get `:update` callback, but all removed children get `:destroy` callback.
#
# Let's add embedded comments to post and see how this works.

# Adding comments to post.
class Post
  def comments; @comments ||= [] end
end

# Defining comment, his teaser also generated with `before_save` callback.
class Comment
  inherit Mongo::Model

  attr_accessor :text, :teaser

  protected
    def generate_teaser
      @teaser = text[0..4] if text
    end
    before_save :generate_teaser
end

# Creating post.
post = Post.new text: 'Norad II crashed!'

# Adding comment to post.
comment = Comment.new text: 'Where?'
post.comments << comment

# Saving post, embedded comment also generates its teaser.
post.save!
p comment.teaser                                  # => 'Where'

# In this example we examined callbacks, it's types and how they works on
# main and embedded models.
#
# [mongodb_model]:     index.html