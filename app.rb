# -*- coding: utf-8 -*-
require 'rubygems'
require 'sinatra'
require 'open-uri'
require 'lib/converter'
require 'lib/rss_generator'

get '/' do
  erb :index
end

post '/w' do
  begin
    raise unless /\Ahttp/ =~ params[:left] and /\Ahttp/ =~ params[:right]
    conv = Converter.new(params[:left], params[:right])
    filename = conv.convert
    redirect "/w/#{filename}"
  rescue
    redirect "/"
  end
end

require 'lib/pagenate'
get '/w/list' do
  dir = "./result/"

  params[:page] ||= 1
  params[:per_page] ||= 5
  total = `find #{dir} -type f | wc -l`.to_i
  @pagenate = Pagenate.new(params[:page], params[:per_page], total)

  files = Dir.glob("#{dir}*").sort{|a,b| File.mtime(b) <=> File.mtime(a)}
  files = files.map {|f| f.gsub(dir, '') }

  @photos = files[@pagenate.offset..(@pagenate.offset + @pagenate.per_page - 1)]

  erb :list
end

get '/w/:id' do
  content_type :jpg
  File.open("./result/#{File.basename(params[:id])}") do |f|
    f.read
  end
end

get '/podcast/:genre.rss' do |genre|
  raise Sinatra::NotFound unless RssGenerator::TITLES.keys.include?(genre.to_s)

  content_type 'application/rss+xml', :charset => 'utf-8'
  @rss = RssGenerator.new(genre).generate
  erb :rss, :layout => :false
end
