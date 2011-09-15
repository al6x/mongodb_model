**Documentation:** http://alexeypetrushin.github.com/mongodb_model

Object Model for MongoDB (callbacks, validations, mass-assignment, finders, ...).

- The same API for pure driver and Models.
- Minimum extra abstractions, trying to keep things as close to the MongoDB semantic as possible.
- Schema-less, dynamic (with ability to specify types for mass-assignment).
- Models can be saved to any collection, dynamically.
- Full support for composite / embedded objects (validations, callbacks, ...).
- Scope, default_scope
- Doesn't try to mimic ActiveRecord, MongoDB is differrent and the Object Model designed to get most of it.
- Works with multiple connections and databases.
- Associations.
- Very small, see [code stats][code_stats].

Other ODM usually try to cover simple but non-standard API of MongoDB behind complex ORM-like abstractions. This tool **exposes simplicity and power of MongoDB and leverages its differences**.

``` ruby
# Basic example of working with [Mongo Model][mongodb_model].
#
# In this example we'll create simple model and examine basic CRUD and
# querying operations.
require 'mongo/model'

# Connecting to test database and cleaning it before starting.
Mongo::Model.default_database_name = :default_test
Mongo::Model.default_database.clear

# Let's define Game Unit.
# Models are just plain Ruby Objects, there's no any Attribute Scheme,
# Types, Proxies, or other complex stuff, just use standard Ruby practices.
class Unit
  # Inheriting our Unit Class from Mongo::Model (the `inherit` keyword is
  # just a simple shortcut including Module and its ClassMethods).
  inherit Mongo::Model

  # You can specify collection name explicitly or omit it and it will be
  # guessed from the class name.
  collection :units

  # There's no need to define attributes, just use plain old Ruby technics to
  # of working with objects.
  attr_accessor :name, :status, :stats

  def inspect; name end
end

# Stats conaining statistics about Unit (it will be embedded into the
# Unit).
#
# There are no difference between main and embedded objects, all of them
# are just standard Ruby objects.
class Unit::Stats
  inherit Mongo::Model

  attr_accessor :attack, :life, :shield
end

# Let's create two great Heroes.
zeratul  = Unit.new name: 'Zeratul',  status: 'alive'
zeratul.stats =  Unit::Stats.new attack: 85, life: 300, shield: 100

tassadar = Unit.new name: 'Tassadar', status: 'dead'
tassadar.stats = Unit::Stats.new attack: 0,  life: 80,  shield: 300

# Saving units to database
p zeratul.save                                    # => true
p tassadar.save                                   # => true

# We made error - mistakenly set Tassadar's attack as zero, let's fix it.
tassadar.stats.attack = 20
p tassadar.save                                   # => true

# Querying, use standard MongoDB query.
p Unit.first(name: 'Zeratul')                     # => Zeratul
p Unit.all(name: 'Zeratul')                       # => [Zeratul]
Unit.all name: 'Zeratul' do |unit|
  p unit                                          # => Zeratul
end

# Simple dynamic finders (bang versions also availiable).
p Unit.by_name('Zeratul')                         # => Zeratul
p Unit.first_by_name('Zeratul')                   # => Zeratul
p Unit.all_by_name('Zeratul')                     # => [Zeratul]

# In this example we covered basics of [Mongo Model][mongodb_model],
# please go to [contents][mongodb_model] for more samples.
#
# [mongodb_model]:     index.html
```

# Installation

``` bash
gem install mongodb_model
```

# License

Copyright (c) Alexey Petrushin, http://petrush.in, released under the MIT license.