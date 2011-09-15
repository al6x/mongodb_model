# Validations in [Mongo Model][mongodb_model].
#
# There are following validation helpers available:
#
#     validates_format_of
#     validates_length_of
#     validates_numericality_of
#     validates_acceptance_of
#     validates_confirmation_of
#     validates_presence_of
#     validates_true_for
#     validates_exclusion_of
#     validates_inclusion_of
#
# In this example we'll create simple models for Blog application and
# use validations to ensure it's correctness.
require 'mongo/model'

# Connecting to test database and cleaning it before starting.
Mongo::Model.default_database_name = :default_test
Mongo::Model.default_database.clear

# ### Basics
#
# Defining Post and requiring presence of text using
# validation helpers.
class Post
  inherit Mongo::Model
  collection :posts

  attr_accessor :text

  # Requiring presence of text.
  validates_presence_of :text
end

# Creating post, it can't be saved because its text is empty and it's invalid.
post = Post.new
p post.valid?                                     # => false
p post.errors.size                                # => 1
p post.errors                                     # => {text: ["can't be empty"]}
p post.save                                       # => false

# Let's add text to it so it will be valid and we can save it.
post.text = 'Norad II crashed!'
p post.valid?                                     # => true
p post.save                                       # => true

# Usually when model is invalid it can't be saved, but if You need You can skip
# validation and save invalid model.
post = Post.new
p post.valid?                                     # => false
p post.save(validate: false)                      # => true

# ### Custom validations

# In previous sample ve used `validates_presence_of` helper to
# require presence of post text, let's do the same by hand.
#
# Removing and creating new Post class.
Object.send :remove_const, :Post

class Post
  inherit Mongo::Model
  collection :posts

  attr_accessor :text

  protected
    # Creating method that valdiates text is not empty.
    def validate_text
      errors.add :text, "can't be empty" unless text and !text.empty?
    end
    # Adding this method to validations (You can also use block instead of
    # method).
    validate :validate_text
end

# Creating and saving new post.
post = Post.new
p post.valid?                                     # => false
p post.errors                                     # => {text: ["can't be empty"]}
p post.save                                       # => false

# Let's text it so it will be valid and we can save it.
post.text = 'Norad II crashed!'
p post.valid?                                     # => true
p post.save                                       # => true

# ### Embedded Models
#
# MongoDB encourage to use Embedded Models a lot, so it's important
# to provide validations for it.

# Adding comments to Post.
class Post
  def comments; @comments ||= [] end
end

# Defining Comment.
class Comment
  inherit Mongo::Model

  attr_accessor :text

  # Validating presence of text in comment.
  validates_presence_of :text
end

# Creating post, there's text and it's valid.
post = Post.new text: 'Norad II crashed!'
post.valid?                                       # => true

# Creating invalid comment with empty text.
comment = Comment.new
p comment.valid?                                  # => false

# Validation of Parent model also does validation on all it's
# childs, so adding invalid comment to valid post will make
# post also invalid.
post.comments << comment
p post.valid?                                     # => false
p post.save                                       # => false

# In order to save post we need to make the comment valid.
comment.text = "Where?"
p comment.valid?                                  # => true
p post.valid?                                     # => true
p post.save                                       # => true

# In this example we examined validation helpers, custom validation and
# validations for embedded models.
#
# [mongodb_model]:     index.html