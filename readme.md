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
# Connecting to MongoDB.
require 'mongo/model'
Mongo.defaults.merge! symbolize: true, multi: true, safe: true
connection = Mongo::Connection.new
db = connection.db 'default_test'
db.units.drop
Mongo::Model.db = db

# Let's define the game unit.
class Unit
  inherit Mongo::Model
  collection :units

  attr_accessor :name, :status, :stats

  scope :alive, status: 'alive'

  class Stats
    inherit Mongo::Model
    attr_accessor :attack, :life, :shield
  end
end

# Create.
zeratul  = Unit.build(name: 'Zeratul',  status: 'alive', stats: Unit::Stats.build(attack: 85, life: 300, shield: 100))
tassadar = Unit.build(name: 'Tassadar', status: 'dead',  stats: Unit::Stats.build(attack: 0,  life: 80,  shield: 300))

zeratul.save
tassadar.save

# Udate (we made error - mistakenly set Tassadar's attack as zero, let's fix it).
tassadar.stats.attack = 20
tassadar.save

# Querying first & all, there's also :each, the same as :all.
Unit.first name: 'Zeratul'                         # => zeratul
Unit.all name: 'Zeratul'                           # => [zeratul]
Unit.all name: 'Zeratul' do |unit|
  unit                                             # => zeratul
end

# Simple finders (bang versions also availiable).
Unit.by_name 'Zeratul'                             # => zeratul
Unit.first_by_name 'Zeratul'                       # => zeratul
Unit.all_by_name 'Zeratul'                         # => [zeratul]

# Scopes.
Unit.alive.count                                   # => 1
Unit.alive.first                                   # => zeratul

# Callbacks & callbacks on embedded models.

# Validations.

# Save model to any collection.
```

Source: examples/model.rb