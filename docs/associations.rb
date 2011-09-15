# Example of Associations in [Mongo Model][mongodb_model].
#
# MongoDB is Document Database, and unlike the Relational Database its key
# feature is Composite Documents. It support Associations also but
# there are some limitations.
#
# So, with MongoDB You usually use Composite Documents
# a lot and Associations not so much.
#
# According to this Mongo Model provides You with advanced tools for [Composite Models][composite],
# and basic only for modelling Associations.
#
# In this example we'll create simple Blog Application and see how to associate
# Comments with the Post using one-to-many association (take a look at the [composite][composite] example
# to see how to embed Comments into Post).
require 'mongo/model'

# Connecting to test database and cleaning it before starting.
Mongo::Model.default_database_name = :default_test
Mongo::Model.default_database.clear

# ### Basics

# Defining Post.
class Post
  inherit Mongo::Model
  # Storing post in `posts` collection.
  collection :posts

  attr_accessor :text

  # Creating and returning [Query Object][queries] that can be used
  # later to select comments belongign to this post (there's no
  # database call at this point).
  def comments
    Comment.where post_id: _id
  end
  # If the post will be destroyed, all comments also should be destroyed.
  after_destroy{|post| post.comments.each(&:destroy!)}

  def inspect; text.to_s end
end

# Defining Comment.
class Comment
  inherit Mongo::Model
  # Storing comment in `comments` collection.
  collection :comments

  attr_accessor :text

  # Every comment has `post_id` attribute with `_id` of corresponding post.
  attr_accessor :post_id
  # We need to ensure that comment always belongs to some post.
  validates_presence_of :post_id

  # Adding method allowing to assign post to comment.
  def post= post
    self.post_id = post._id
    _cache[:post] = post
  end
  # Retrieving the post this comment belongs to.
  def post
    _cache[:item] ||= Post.by_id post_id
  end

  def inspect; text.to_s end
end

# Creating Post with Comments and saving it to database.
post = Post.create text: 'Zerg infestation found on Tarsonis!'
post.comments.create text: "I can't believe it."

# Retrieving post and comments.
post = Post.first
p post.text                                      # => "Zerg infestation found on Tarsonis!"
p post.comments.count                            # => 1
p post.comments.first.text                       # => "I can't believe it."
p post.comments.first.post == post               # => true

# You can also add comments directly, without any syntaxis sugar.
comment = Comment.new text: "Me too, but it's true."
comment.post = post
comment.save
p post.comments.count                             # => 2

# Comments belonging to post are returned as [Query Object][queries]
# thus giving You access to all kind of operations.
per_page = 2
p post.comments.paginate(1, per_page).all         # => first page of comments

# After destroying the post all dependent comments also should be destroyed.
post.destroy
p Comment.count                                   # => 0

# ### Caching comments count.
#
# It would be nice to know how many comments does the post have withoug
# executing additional query to count it, let's do this by caching it in
# the `comments_count` attribute of the post.

# Adding `comments_count` attribute to Post.
class Post
  attr_writer :comments_count
  def comments_count; @comments_count ||= 0 end
end

# Updating `comments_count` every time comment created and destroyed. Actually
# we can do this by retrieving, updating and then saving the post, but let's
# do it in more efficient way using [modifiers][modifiers].
class Comment
  after_create do |comment|
    Post.update({_id: comment.post_id}, {_inc: {comments_count: 1}})
  end
  after_destroy do |comment|
    Post.update({_id: comment.post_id}, {_inc: {comments_count: -1}})
  end
end

# Now, every time comment will be created and destroyed, post `comments_count`
# attribute will be updated.
post = Post.create text: 'Zerg infestation found on Tarsonis!'
post.comments.create text: "I can't believe it."
post.reload
p post.comments_count                            # => 1
post.comments.destroy_all
post.reload
p post.comments_count                            # => 0

# In this example we covered 1-to-N association, but You can implement all
# other types using similar technics (the only complex case is
# M-to-N - use array of ids to do it).
#
# Also, remember that MongoDB is Document Database, not Relational.
# If You want to get most of it – use Composite Documents whenever possible,
# avoid Associations and use it only if You really need it.
#
# [mongodb_model]:     index.html
#
# [composite]:    composite.html
# [queries]:      aueries.html
# [modifiers]:    modifiers.html