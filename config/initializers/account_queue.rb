Dir["#{Rails.root}/lib/**/*.rb"].sort.each do |item|
  require item
end
AccountStore.little_store!