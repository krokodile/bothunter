if ENV['THREAD_COUNT'] =~ /^(\d+)$/
  THREAD_COUNT = $1.to_i
else
  THREAD_COUNT = 80
end
PARSE_USERS_THREADS = 30
PARSE_GROUPS_THREADS = 50
