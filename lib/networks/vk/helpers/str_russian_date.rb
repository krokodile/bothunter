# encoding: utf-8

def str_russian_date str
  if str
    str.gsub!(/вчера/, 1.day.ago.strftime("%d %m %Y").to_s)
    str.gsub!(/сегодня/, Time.now.strftime("%d %m %Y").to_s)

    mounths = %w[января февраля марта апреля мая июня июля августа сентября октября ноября декабря]
    mounths.each do |mounth|
      str.gsub!(mounth, (mounths.index(mounth) + 1).to_s) if str =~ /#{mounth}/
    end

    mounths = %w[янв фев мар апр мая июн июл авг сен окт ноя дек]
    mounths.each do |mounth|
      str.gsub!(mounth, (mounths.index(mounth) + 1).to_s) if str =~ /#{mounth}/
    end

    str.gsub!(/Одну/, '1')
    str.gsub!(/\ +в/, ' в')

    hours = %w[Один Два Три Четыре Пять]
    hours.each do |hour|
      str.gsub!(hour, (hours.index(hour) + 1).to_s) if str =~ /#{hour}/
    end

    if str =~ / назад/
      str.gsub!(/ назад/, '')
    
      if str =~ /^(\d+)\ минут[уы]?/
        return $1.to_i.minutes.ago.to_datetime
      elsif str =~ /^(\d+)\ час[ова]+?/
        return $1.to_i.hours.ago.to_datetime
      elsif str =~ /^(\d+)\ секунд[ы]?/
        return $1.to_i.seconds.ago.to_datetime
      end
    elsif str =~ /только что/
      return Time.now
    end

    if str =~ /^\d+\ \d+\ \d+\ в\ \d+\:\d+$/
      DateTime.strptime(str, "%d %m %Y в %H:%M")
    elsif str =~ /^\d+\ \d+\ в\ \d+\:\d+$/
      DateTime.strptime(str, "%d %m в %H:%M")
    elsif str =~ /^\d+\ \d+\ \d+$/
      DateTime.strptime(str, "%d %m %Y")
    end
  end
end

def russian_date_scan str
  _date = str.scan(/(\d+\ [а-я]+(\ \d+)?\ +в\ \d+\:\d+)/).first.presence ||
           str.scan(/((Один|Два|Три|Четыре|Пять|\d+)\ (минут[уы]|час[ова]+|секунд[ы])\ назад)/).first.presence ||
           str.scan(/(только что)/).first.presence ||
           str.scan(/((сегодня|вчера)\ +в\ \d+\:\d+)/).first.presence ||
           str.scan(/(сегодня|вчера)/).first.presence ||
           str.scan(/(\d+\ [а-я]+\ \d+)/).first.presence

  if _date
    str_russian_date _date.first
  end
end
