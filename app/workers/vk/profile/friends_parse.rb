class FriendsParse
  def self.perform uid
    page = ::Vkontakte.http_get("/friends?id=#{uid}&section=all").to_nokogiri_html
    puts (page / '#friends_summary')
    friends_count = /.* (\d+) .*/.match((page / '#friends_summary').first.content)[1].to_i
    person = Person.where(uid:uid).first
    person.friends_count = friends_count
    person.save
  end
end