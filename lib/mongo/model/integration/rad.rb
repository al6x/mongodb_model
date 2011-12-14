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

# Using DB connection setting defined in component's config file.
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