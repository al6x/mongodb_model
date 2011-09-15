# Conversions for [Mongo Model][mongodb_model].
#
# In this example we'll create simpel Blog and discover how to
# convert models to JSON, filter attributes, and define conversion
# profiles for [Composite Model][composite].
require 'mongo/model'

# Connecting to test database and cleaning it before starting.
Mongo::Model.default_database_name = :default_test
Mongo::Model.default_database.clear

# Defining Post with Comments.
class Post
  inherit Mongo::Model
  collection :posts

  attr_accessor :text, :token

  def comments; @comments ||= [] end
end

class Comment
  inherit Mongo::Model

  attr_accessor :text, :token
end

# Creating post and converting it to JSON:
#
#     {
#       text:     'Zergs found!',
#       token:    10
#       comments: [
#         {
#           text:  'Where?',
#           token: 11
#         },
#         {
#           text:  'On Tarsonis.',
#           token: 12
#         }
#       ]
#     }
#
post = Post.new text: 'Zergs found!', token: 10
post.comments << Comment.new(text: 'Where?', token: 11)
post.comments << Comment.new(text: 'On Tarsonis.', token: 12)
puts post.to_json

# We can filter attributes using `:only`, `:except`, `:methods` options.
#
#     {
#       text: 'Zergs found!'
#     }
#
puts post.to_json(only: :text)

# ### Profiles
#
# You can use filter options to control what attributes will be converted
# to JSON, but this filters won't allow You to specify attributes on embedded
# models. To do so You need to use conversion profiles.

# Those tokens on post and comments are secret and we don't want to expose it
# to public. We need to define profile that will filter these secret tokens.
class Post
  profile :public, except: :token
end
class Comment
  profile :public, except: :token
end

# Now we can use `public` profile in conversion and filter `token` attributes:
#
#     {
#       text:     'Zergs found!',
#       comments: [
#         {
#           text:  'Where?'
#         },
#         {
#           text:  'On Tarsonis.'
#         }
#       ]
#     }
#
puts post.to_json(profile: :public)

# In this example we covered conversions, attribute filtering and
# conversion profiles.
#
# [mongodb_model]:     index.html
# [composite]:         composite.html