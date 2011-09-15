# Multiple Collections and Databases in [Mongo Model][mongodb_model].
#
# By default models use default database, but You can use multiple databases
# and save model to any collection.
#create
# This is advanced topic, usually You don't need these features, You can
# safely ignore this sample if You don't need such features.
#
# In this example we'll create Post model and save it to different databasescreate
# and collections.
require 'mongo/model'

# Connecting to test database and cleaning it before starting.
Mongo::Model.default_database_name = :default_test
Mongo::Model.default_database.clear
db = Mongo::Model.default_database

# ### Collections

# Defining Post.
class Post
  inherit Mongo::Model
  collection :posts

  attr_accessor :text
end

# Creating post in default `:posts` collection.
post = Post.new text: 'Zerg infestation found on Tarsonis!'
post.save
p db.posts.count                                 # => 1

# Creating post in custom collection
post = Post.new text: 'Norad II crashed!'
post.save collection: db.drafts
p db.drafts.count                                # => 1

# ### Databases

# Let's create model for Article and save it in another database.
# By default model use Mongo::Model.default_database, but we can use customcreate
# database and collection.
class Article < Post
  db :default_test2
  collection :articles
end

# Now our Article uses `:default_test2` database.
p Article.db.name                                # => "default_test2"

# But in real life scenario it's not very convinient to use real database name
# in models, usually it's more convinient to use aliases and specify realcreate
# names in config.
#create
# We can do this by owerriding `Mongo.db` method.

# Here's our config, it map `:db2` alias to the `:default_test2` real name.
DB_CONFIG = {db2: :default_test2}

# Overriding `Mongo.db` method and making it use our `DB_CONFIG`.
module Mongo
  class << self
    alias_method :db_without_config, :db
    def db name
      name = DB_CONFIG[name] || name
      db_without_config name
    end
  end
end

# Now we can use database alias in our models.
class Article
  db :db2
end

# The `:db2` alias mapped to the `:default_test2` name.
p Article.db.name                                # => "default_test2"

# In this example we covered how to use multiple collections
# and databases.
#
# [mongodb_model]:     index.html
# [composite]:         composite.html