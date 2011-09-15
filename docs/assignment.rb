# Mass assignment for [Mongo Model][mongodb_model].
#
# In this example we'll discover how to define attribute types,
# and protect some of them from mass assignment.
require 'mongo/model'

# Connecting to test database and cleaning it before starting.
Mongo::Model.default_database_name = :default_test
Mongo::Model.default_database.clear

# Let's define User.
class User
  inherit Mongo::Model

  attr_accessor :name, :age
end

# By defautl there's no any types and You can assign anything to
# any attribute using the `set` method.
user = User.new
user.set name: 'Gordon Freeman', age: '28'
p [user.name, user.age]                          # => ['Gordon Freeman', '28']

# In previous example the `age` attribute is supposed to be Integer but
# it has been assigned as String.
# This is wrong, we need to fix it.
class User
  # Declaring attribute tupes, and allowing to update it in mass assignment.
  assign do
    name String,  true
    age  Integer, true
  end

  # There's also another version of declaring attribute type.
  assign :name, String, true
end

# Assigning values to attributes, this time String has been casted to Integer before
# assigning and the `age` attribute has correct type.
user.set name: 'Gordon Freeman', age: '28'
p [user.name, user.age]                          # => ['Gordon Freeman', 28]

# There are some sensitive attributes that shouldn't be allowed to
# assigned in mass assignment, let's add the `password` attribute and make it
# protected.
class User
  # Actually there's no need to explicitly specify that attribute is protected,
  # if You don't explicitly allow it to mass assignment it will be protected by default.
  attr_accessor :password
end

# If we try to to change `password` using mass assignment we got an exception,
# You can forcefully assign protected attribute if You want.
user.set(password: 'Black Mesa') rescue p('No!') # => "No!"
p user.password                                  # => nil
user.set! password: 'Black Mesa'
p user.password                                  # => "Black Mesa"

# [mongodb_model]:     index.html