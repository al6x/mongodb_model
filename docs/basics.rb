# Basic example of working with [Mongo Object Model][mongodb_model].
require 'mongo/model'

# Connecting to test database and cleaning it before starting the sample.
Mongo::Model.default_database_name = :default_test
Mongo::Model.default_database.drop

# Let's define the first model - Game Unit.
# Models are just standard Ruby Objects, there's no any Attribute Scheme,
# Types, Proxies, or any other complex stuff, just use standard Ruby practices.
class Unit
  # Inheriting our Unit Class from Mongo::Model (please don't be afraid
  # of `inherit` keyword, it's just a shortcut to do `self.included` pattern).
  inherit Mongo::Model

  # You can specify collection name explicitly or omit it and it will be
  # guessed from the Class name.
  collection :units

  # Use plain old Ruby `attr_accessor` to define attributes.
  attr_accessor :name, :status, :stats
end

# Stats conaining statistics about Unit (it will be embedded into the
# Unit).
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
p Unit.first(name: 'Zeratul')                     # => zeratul
p Unit.all(name: 'Zeratul')                       # => [zeratul]
Unit.all name: 'Zeratul' do |unit|
  p unit                                          # => zeratul
end

# Simple finders (bang versions also availiable).
p Unit.by_name('Zeratul')                         # => zeratul
p Unit.first_by_name('Zeratul')                   # => zeratul
p Unit.all_by_name('Zeratul')                     # => [zeratul]

# In this example we covered basics of [Mongo Object Model][mongodb_model], if You are interesting
# here are more detailed examples:
#
# [composite][composite], [querying][querying], [scope][scope],
# [validations][validations], [callbacks][callbacks], [conversion][conversion],
# [associations][associations], [assignment][assignment], [database][database],
# [migrations][migrations].
#
# [mongodb_model]:     index.html
# [migrations]:   http://alexeypetrushin.github.com/mongodb/migration.html
# [callbacks]:    callbacks.html
# [associations]: associations.html
# [assignment]:   assignment.html
# [validations]:  validations.html
# [querying]:     querying.html
# [scope]:        scope.html
# [conversion]:   conversion.html
# [database]:     database.html
# [composite]:    composite.html