# Modeifiers in [Mongo Model][mongodb_model].
#
# Usually if You want to update model You load it, make changes
# and save it back. But if You want to update only some of attributes
# there's more efficient way - modifiers.
#
# In this example we'll create simpel model and update it using modifiers.
require 'mongo/model'

# Connecting to test database and cleaning it before starting.
Mongo::Model.default_database_name = :default_test
Mongo::Model.default_database.clear

# Defining game Unit.
class Unit
  inherit Mongo::Model
  collection :units

  attr_accessor :name, :life
end

# Creating brave Tassadar.
tassadar = Unit.create name: 'Tassadar', life: 80

# Updating model with modifiers.
tassadar.update _inc: {life: -40}
tassadar.reload
p tassadar.life                                  # => 40

# There's also helper on the model class.
Unit.update({id: tassadar.id}, {_inc: {life: -20}})
tassadar.reload
p tassadar.life                                  # => 20

# In this example we covered using modifiers.
#
# [mongodb_model]:     index.html
# [composite]:         composite.html