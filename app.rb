require 'rubygems'
require 'sinatra'
require 'hpricot'
require 'open-uri'
require 'lib/converter.rb'

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

get '/w/:id' do
  content_type :jpg
  File.open("./result/#{File.basename(params[:id])}") do |f|
    f.read
  end
end
