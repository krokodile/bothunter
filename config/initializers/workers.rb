Dir.glob(File.expand_path('./app/workers/**/*.rb', Rails.root)).each do |worker|
  require worker
end