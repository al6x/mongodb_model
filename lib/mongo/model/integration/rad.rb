# Registering it as component.

class Mongo::Model::Component
  attr_accessor :db
  attr_required :db

  attr_accessor :fs
  attr_required :fs
end

rad.register :models do
  Mongo::Model::Component.new
end

# Connection settings defined in the `models.yml` config file for the :models component.
#
# Sample of `models.yml` config file, it cotains database names and connection settings.
#
#   db:
#     default:
#       host: localhost
#       port: 4029
#       name: my_web_app
#     tmp:
#       name: all_sorts_of_tmp_data
#
# Note that we use logical name of the database, the real name can be different. It gives You flexibility and
# allows You to use the same logical name, but it can mean different databases with different real names in
# let's say :development and :production evnironments:
#
# Usage - if not specified the :default alias will be used:
#
#   class Blog
#   end
#
# You can also explicitly specify what alias should be used:
#
#   class Token
#     db :tmp
#   end
#
Mongo.metaclass_eval do
  def db name
    config = rad.models.db[name.to_s] || raise("no database config for #{name} alias!")
    host, port, options = config['host'], config['port'], (config['options'] || {})
    connection = self.connection host, port, options
    db_name = config['name'] || raise("no database name for #{name} alias!")
    connection.db db_name
  end
  cache_method_with_params :db

  def connection host, port, options
    options[:logger] = rad.logger unless options.include? :logger
    Mongo::Connection.new host, port, options
  end
  cache_method_with_params :connection
end

# Localization

Mongo::Model::Misc.class_eval do
  def t *args; rad.locale.t *args end
end

Mongo::Model::Misc::ClassMethods.class_eval do
  def t *args; rad.locale.t *args end
end