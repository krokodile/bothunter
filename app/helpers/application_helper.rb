module ApplicationHelper
  def link_highlight title, link, *args, &block
    li_class = if parse_uri(link) == parse_uri(request.env['PATH_INFO'])
                 'active'
               else
                 nil
               end

    content_tag :li, class: li_class do
      if block_given?
        link_to link, *args, &block
      else
        link_to title, link, *args
      end
    end
  end

  def parse_uri str
    str.gsub(/\?.*/, '').gsub(/\#.*/, '')
  end

  def clippy text, bgcolor='#FFFFFF'
    html = <<-EOF
    <object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000"
            width="110"
            height="14"
            id="clippy" >
    <param name="movie" value="/assets/clippy.swf"/>
    <param name="allowScriptAccess" value="always" />
    <param name="quality" value="high" />
    <param name="scale" value="noscale" />
    <param NAME="FlashVars" value="text=#{text}">
    <param name="bgcolor" value="#{bgcolor}">
    <embed src="/assets/clippy.swf"
           width="110"
           height="14"
           name="clippy"
           quality="high"
           allowScriptAccess="always"
           type="application/x-shockwave-flash"
           pluginspage="http://www.macromedia.com/go/getflashplayer"
           FlashVars="text=#{text}"
           bgcolor="#{bgcolor}"
    />
    </object>
    EOF
  end

  def random_words_string
    (WORDS.shuffle[0..1] + [rand(1000)]).join('-')
  end
end
