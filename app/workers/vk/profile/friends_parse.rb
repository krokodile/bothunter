class FriendsParse
  @queue = "bothunter"
  def self.perform uid
    page = ::Vkontakte.http_get("/friends?id=#{uid}&section=all").to_nokogiri_html
    puts (page / '#friends_summary')
    friends_count = 0
    begin
      friends_count = /.* (\d+) .*/.match((page / '#friends_summary').first.content)[1].to_i
    rescue Exception => e
      friends_count = 0
    end
    
    person = Person.where(uid:uid).first
    if person.present?
	    person.friends_count = friends_count
	    person.save
    end
  end
end