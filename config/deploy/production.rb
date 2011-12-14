domain = 'scrm.myhotspot.ru'
role :web, "scrm.myhotspot.ru:8080"
#server 'scrm.myhotspot.ru', :web, :app
#server domain, :db, :primary => true

set :port, 2122
set :branch, "master"
set :rails_env, "production"
set :environment, "production"
