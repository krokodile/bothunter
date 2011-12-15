domain = 'scrm.myhotspot.ru'
server 'scrm.myhotspot.ru', :web, :app
#server domain, :db, :primary => true

set :port, 2122
set :branch, "master"
set :rails_env, "production"
set :environment, "production"
