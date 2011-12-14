require 'mongo/migration/tasks'

namespace :db do
  desc "Internal task to prepare migration environment"
  task migration_evnironment: :environment do
    require 'mongo/migration'

    Dir["#{rad.runtime_path}/db/**/*.rb"].each{|f| require f.sub(/\.rb$/, '')}
  end
end