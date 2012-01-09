class ParseUsers
  @queue = "bothunter"
  def self.perform
    puts "Parsing users"
    persons = ::Person.where(state: :pending).all
    threads_count = 50
    client = ::Vk::Client.new
    threads = []
    persons.each do |person|
      threads = threads.find_all {|thr| thr["state"]==:work}
      if threads.size>=threads_count
        threads.each {|thr| thr.join }
        threads = []
      end
      threads << Thread.new do
        Thread.current["state"] = :work
        begin
          Vk::ProfileParse.perform(person,client)
        rescue Exception=>e
          Thread.current["state"] = :error
        else
          Thread.current["state"] = :end
        end

      end

    end
  end
end
