class Object
  def to_plain
    _res = self.to_s.gsub('</div>', "\n").gsub(/<\/?[^>]*>/, '').strip.gsub(/:$/, '')
    CGI.unescapeHTML(_res)
  end
end
