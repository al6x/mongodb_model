# Object Model for MongoDB.
#
# [basics][basics], [composite][composite], [queries][queries],
# [validations][validations], [callbacks][callbacks], [associations][associations],
# [assignment][assignment], [conversions][conversions], [modifiers][modifiers],
# [database][database], [migrations][migrations].
#
# Features:
#
# - Same API for [Driver][driver] and Object Model.
# - Minimum extra abstractions, trying to keep things as close to the MongoDB semantic as possible.
# - [Schema-less, dynamic][basics] (with ability to specify types for [mass-assignment][assignment]).
# - Models can be saved to [any collection][database], dynamically.
# - Full support for [composite / embedded objects][composite] (with [validations][validations],
# [callbacks][callbacks], ...).
# - [Scope][queries], default scope.
# - Doesn't try to mimic ActiveRecord, MongoDB is differrent and the Object Model designed to get most of it.
# - Works with [multiple][database] connections and databases.
# - Support for [associations][associations].
# - Small codebase, see [code stats][code_stats].
#
# This tool **exposes simplicity and power of MongoDB and leverages its differences**.
#
# Install mongodb with Rubygems:
#
#     gem install mongodb
#
# The project is [hosted on GitHub][project]. You can report bugs and discuss features
# on the [issues page][issues].
#
# [project]:      https://github.com/alexeypetrushin/mongodb_model
# [issues]:       https://github.com/alexeypetrushin/mongodb_model/issues
#
# [driver]:       http://alexeypetrushin.github.com/mongodb
# [code_stats]:   code_stats.png
#
# [migrations]:   http://alexeypetrushin.github.com/mongodb/migration.html
# [basics]:       basics.html
# [callbacks]:    callbacks.html
# [associations]: associations.html
# [assignment]:   assignment.html
# [modifiers]:    modifiers.html
# [validations]:  validations.html
# [queries]:      queries.html
# [conversions]:  conversions.html
# [database]:     database.html
# [composite]:    composite.html