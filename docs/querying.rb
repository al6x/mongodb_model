# Example of Querying using [Mongo Object Model][mongodb_model].
#
# In this example we'll see standard MongoDB queries, dynamic finders and scopes.
require 'mongo/model'

# Connecting to test database and cleaning it before starting.
Mongo::Model.default_database_name = :default_test
Mongo::Model.default_database.clear

# Defining Game Unit.
class Unit
  inherit Mongo::Model
  collection :units

  attr_accessor :name, :status, :race

  def inspect; name end
end

# Populating database.
zeratul  = Unit.create name: 'Zeratul',  race: 'Protoss', status: 'alive'
tassadar = Unit.create name: 'Tassadar', race: 'Protoss', status: 'dead'
jim      = Unit.create name: 'Jim',      race: 'Terran',  status: 'alive'

# Standard MongoDB queries (there's also `each` method, the same as `all`).
p Unit.first(name: 'Zeratul')                        # => Zeratul
p Unit.all(name: 'Zeratul')                          # => [Zeratul]
Unit.all name: 'Zeratul' do |unit|
  p unit                                             # => Zeratul
end

# Simple dynamic finders.
p Unit.by_name('Zeratul')                            # => Zeratul
p Unit.first_by_name('Zeratul')                      # => Zeratul
p Unit.all_by_name('Zeratul')                        # => [Zeratul]

# Bang version, will raise error if nothing found.
p Unit.first!(name: 'Zeratul')                       # => Zeratul
p Unit.by_name!('Zeratul')                           # => Zeratul

# Counting and existence checking.
p Unit.count                                         # => 3
p Unit.count(race: 'Protoss')                        # => 2
p Unit.exist?(name: 'Zeratul')                       # => true
p zeratul.exist?                                     # => true

# You can use Query Builder for complex queries, let's write
# sample query with and without it.
p Unit.all({race: 'Protoss'}, {sort: [[:name, -1]]}) # => [Zeratul, Tassadar]
p Unit.where(race: 'Protoss').sort([:name, -1]).all  # => [Zeratul, Tassadar]
p Unit.where(race: 'Protoss').sort(:name).all        # => [Tassadar, Zeratul]

# Sometimes it's handy to define frequently used queries
# on the model, such queries called scopes.
class Unit
  # Specifying `alive` scope to easilly select all alive units.
  scope :alive, status: 'alive'

  # If You provide block, it will be dynamically
  # calculated for each query.
  #
  # You can also specify `default_scope` it's defined like
  # normal scope but unlike it it's always implicitly applied
  # to all queries.
  scope(:terrans){{race: 'Terran'}}
end

# Now we can use those scopes in queries. Scopes are chainable, so You can use any
# standard `first`, `all`, `find_by`, `count` method as well as another
# scopes.
p Unit.alive.count                                   # => 2
p Unit.alive.first                                   # => Zeratul
p Unit.alive.by_name('Zeratul')                      # => Zeratul
p Unit.alive.terrans.first                           # => Jim
p Unit.alive.where(race: 'Protoss').first            # => Zeratul

# Using pagination.
per_page = 2
p Unit.paginate(1, per_page).sort(:name).all         # => [Jim, Tassadar]
p Unit.paginate(2, per_page).sort(:name).all         # => [Zeratul]

# Mongo Object Model is tightly integrated with [Driver][mongodb],
# so You can also use its API for querying.
db = Mongo::Model.default_database
p db.units.first(name: 'Jim')                        # => Jim
p db.units.first(name: 'Jim').class                  # => Unit

# In this example we covered how to use standard MongoDB queries,
# dynamic finders, scopes and query builder.
#
# [mongodb]:           http://alexeypetrushin.github.com/mongodb
# [mongodb_model]:     index.html