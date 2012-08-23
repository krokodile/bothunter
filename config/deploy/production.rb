domain = '89.104.91.109'
server '89.104.91.109', :web, :app
#server domain, :db, :primary => true

set :port, 2122
set :branch, "develop"
set :rails_env, "production"
set :environment, "production"
