# -*- coding: utf-8 -*-
require 'rubygems'
require 'RMagick'
require 'objectdetect'
require 'digest/sha1'

class Converter
  include Magick

  def initialize(left, right)
    save(left); save(right)
    @left, @right = left, right
    @height = 200
    @setting = "./config/haarcascade_frontalface_alt2.xml"
  end

  def convert
    left = cut(save_path(@left), :left)
    right = cut(save_path(@right), :right)
    background = Image.new(right.columns + left.columns, @height)
    result = background.composite(left, NorthWestGravity, OverCompositeOp)
    result = result.composite(right, NorthEastGravity, OverCompositeOp)
    result.format = "JPEG"
    filename = Digest::SHA1.hexdigest(@left + @right)
    result.write("./result/" + filename)
    return filename
  end

  private
  def save_path(url)
    "/tmp/" + Digest::SHA1.hexdigest(url.to_s)
  end

  def save(url)
    File.open(save_path(url), "w"){|f| f.write(open(url).read)}
  end

  def cut(file, left_or_right)
    image = Image.read(file).first
    result = ObjectDetect::detect(@setting, file).map{|rect|
      rect[0] = rect[0] + rect[2] / 2 if left_or_right.to_s == "right"
      rect[2] = rect[2] / 2 # half width
      image.crop(*rect)
    }.first
    result.resize!((result.columns.to_f * (@height / result.rows.to_f)).to_i,
                   @height)
    result.format = "JPEG"
    matte_pct = (left_or_right.to_s == "right") ? "#000000" : "#00FF00"
    result = result.colorize(0.3, 0.3, 0.3, matte_pct)
    result
  end
end
