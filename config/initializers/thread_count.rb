if ENV['THREAD_COUNT'] =~ /^(\d+)$/
  THREAD_COUNT = $1.to_i
else
  THREAD_COUNT = 10
end

