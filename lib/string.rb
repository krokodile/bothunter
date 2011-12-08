#require 'tidy_ffi'
class String
  def to_nokogiri_html tidy=false
    _html = self
    _html = _html.gsub(/^\<\!\-\-[^\<]+/, '').gsub(/\<\!\>[^\<]+\<\!\>/, '')
    _html = _html.gsub(/\<\!--\d+\<\!\>/, '').gsub(/(\d+)?\<\!\>\d+\<\!\>(\d+)?/, '')
    _html = _html.gsub(/\<\!\>\<\!json\>/, '')
    #if tidy
    #  _html = TidyFFI::Tidy.with_options(:char_encoding => 'utf8', :force_output => true).new(_html).clean
    #end
    doc = Nokogiri::HTML.parse _html, nil, 'utf-8'
    doc.css('br').each{ |br| br.replace("\n") }
    doc
  end
end
