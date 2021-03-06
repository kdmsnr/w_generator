# -*- coding: utf-8 -*-
require 'rubygems'
require 'sinatra'
require 'open-uri'
require 'lib/converter'
require 'lib/rss_generator'

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
  alias_method :u, :escape

  def partial(page, options={})
    erb page, options.merge!(:layout => false)
  end
end

get '/' do
  erb :index
end

post '/w' do
  begin
    raise unless /\Ahttp/ =~ params[:left] and /\Ahttp/ =~ params[:right]
    conv = Converter.new(params[:left], params[:right],
                         params[:left_color], params[:right_color])
    filename = conv.convert
    redirect "/w/list" # "/w/#{filename}"
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

delete '/w/:id' do
  File.unlink("./result/#{File.basename(params[:id])}")
  redirect "/w/list"
end

get '/w/:id' do
  content_type :jpg
  File.open("./result/#{File.basename(params[:id])}") do |f|
    f.read
  end
end

get '/podcast' do
  redirect "/podcast/"
end

get '/podcast/' do
  @channels = RssGenerator::TITLES
  erb :podcast_index, :layout => :false
end

get '/podcast/:genre.rss' do |genre|
  raise Sinatra::NotFound unless RssGenerator::TITLES.keys.include?(genre.to_s)

  content_type 'application/rss+xml', :charset => 'utf-8'
  @rss = RssGenerator.new(genre).generate
  erb :rss, :layout => :false
end
