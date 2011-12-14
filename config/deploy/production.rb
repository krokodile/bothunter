domain = 'scrm.myhotspot.ru'
server domain, :web, :app
#server domain, :db, :primary => true

set :port, 2122
set :branch, "feature/worker"
set :rails_env, "production"
set :environment, "production"
