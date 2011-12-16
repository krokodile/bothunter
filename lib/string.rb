#require 'tidy_ffi'
class String
  def to_nokogiri_html tidy=false, gjson=false
    #TODO: gjson - for vk group parsing, quick&dirty fix
    _html = self
    #puts _html
    if gjson
      #puts "GJSON!"
      _html = _html.gsub(/.*<!>0<!><!json>/,"")
      _html = _html.gsub(/<!><!json>.*/,"")
      _html  = ActiveSupport::JSON.decode(_html)['members']
      #puts _html
    else
      _html = _html.gsub(/^\<\!\-\-[^\<]+/, '').gsub(/\<\!\>[^\<]+\<\!\>/, '')
      _html = _html.gsub(/\<\!--\d+\<\!\>/, '').gsub(/(\d+)?\<\!\>\d+\<\!\>(\d+)?/, '')
      _html = _html.gsub(/\<\!\>\<\!json\>/, '')
    end
    #if tidy
    #  _html = TidyFFI::Tidy.with_options(:char_encoding => 'utf8', :force_output => true).new(_html).clean
    #end

    doc = Nokogiri::HTML.parse _html, nil, 'utf-8'
    doc.css('br').each{ |br| br.replace("\n") }
    #puts doc
    doc
  end
end
