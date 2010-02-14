# -*- coding: utf-8 -*-
require 'rubygems'
require 'hpricot'
require 'rss'

class PodcastItem
  attr_accessor :title, :mp3, :date
  def initialize(title, mp3, date)
    @title, @mp3, @date = title, mp3, date
  end

  def date
    Time.mktime(*@date.split(/\./))
  end
end

class RssGenerator
  TITLES = {
    "healing" => "園咲若菜のヒーリングプリンセス",
    "groove" => "FU-TO Hit on Groove",
    "ippon" => "向い風 一本勝負!!"
  }

  def initialize(genre)
    @genre = genre
  end

  def get_items
    items = []
    doc = Hpricot(open("http://windwave.jp/#{@genre}/index.php"))
    (doc/"//script[@language='javascript']").each do |i|
      date = i.parent.parent.previous_sibling.children[1].innerHTML
      i.inner_html.scan(/encodeURI\('([^,]*),(.*\.mp3)'\)/).each do |v|
        item = PodcastItem.new(v[0], v[1], date)
        items << item
      end
    end
    items
  end

  def generate
    if File.exist?("tmp/#{@genre}.rss") and
        (File.ctime("tmp/#{@genre}.rss") > Time.now - 60*60*3)
      return File.open("tmp/#{@genre}.rss").read
    end

    rss = RSS::Maker.make("2.0") do |maker|
      maker.channel.about = "http://windwave.jp/#{@genre}/index.php"
      maker.channel.title = TITLES[@genre]
      maker.channel.description = TITLES[@genre]
      maker.channel.link = "http://windwave.jp/#{@genre}/index.php"

      get_items.each do |i|
        maker.items.new_item do |item|
          item.link = URI.encode(i.mp3)
          item.title = i.title
          item.date = i.date
          item.enclosure.type = "audio/mpeg"
          item.enclosure.url = URI.encode(i.mp3)
          item.enclosure.length = 1
        end
      end
    end

    File.open("tmp/#{@genre}.rss", "w") do |f|
      f.write(rss)
    end

    return rss
  end
end

if __FILE__ == $0
  RssGenerator.new("healing").get_items
end
