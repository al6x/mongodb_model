# Example of Composite Objects using [Mongo Model][mongodb_model].
#
# Models are just ordinary Ruby Objects, so You can combine and mix it as You wish.
# The only differences are
#
# - main object has the `_id` attribute.
# - child objects doesn't have `_id`, but have `_parent` - reference to the main object.
#
# [Callbacks][callbacks], [validations][validations] and [conversions][conversions]
# works on embedded objects the same way as on the main.
#
# In this example we'll create simple Blog Application and see how to embed
# Comments into the Post.
require 'mongo/model'

# Connecting to test database and cleaning it before starting.
Mongo::Model.default_database_name = :default_test
Mongo::Model.default_database.clear

# Defining Post.
class Post
  inherit Mongo::Model
  collection :posts

  attr_accessor :text

  # We using plain Ruby Array as container for Comments.
  def comments; @comments ||= [] end
end

# Defining Comment.
class Comment
  inherit Mongo::Model

  attr_accessor :text

  # We need a way to access Post from Comment, every child object has `_parent` reference, let's
  # use it.
  alias_method :post, :_parent
end

# Creating Post with Comments and saving it to database.
post = Post.new text: 'Zerg infestation found on Tarsonis!'
post.comments << Comment.new(text: "I can't believe it.")
post.save

# Retrieving from database.
post = Post.first
p post.comments.class                         # => Array
p post.comments.size                          # => 1
p post.comments.first.text                    # => "I can't believe it"
p post.comments.first.post == post            # => true

# Adding another comment.
post.comments << Comment.new(text: "Me too, but it's true.")
post.save

# Reading updated post.
post = Post.first
p post.comments.size                           # => 2

# In this example we covered how to create and use composite objects (embedded objects) -
# use plain Ruby Objects and the Driver will figure out how to save and restore it.
#
# [mongodb_model]:     index.html
#
# [callbacks]:    callbacks.html
# [validations]:  validations.html
# [conversions]:  conversions.html