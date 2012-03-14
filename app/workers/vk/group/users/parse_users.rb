class ParseUsers
  @queue = "bothunter"
  def self.perform
    puts "Parsing users"
    persons = ::Person.where(state: :pending).all
    threads_count = PARSE_USERS_THREADS
    threads = []
    Group.all.each do |group|
      persons = group.persons.where(state: :pending).to_a
      #threads = threads.find_all {|thr| thr["state"]==:work}
      persons.each do |person|
        if threads.size>=threads_count
          threads.each {|thr| thr.join }
          threads = []
        end
        threads << Thread.new do
          begin
            Vk::ProfileParse.perform(person)
          rescue Exception=>e
            puts e
          end
        end
     end
    end
  end
end
