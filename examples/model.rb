# Connecting to MongoDB.
require 'mongodb/model'
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