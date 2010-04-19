# -*- coding: utf-8 -*-
require 'rubygems'
require 'RMagick'
require 'objectdetect'
require 'digest/sha1'

class Converter
  include Magick

  def initialize(left, right, left_color = "#000000", right_color = "#00FF00")
    save(left); save(right)
    @left, @right = left, right
    @left_color, @right_color = left_color, right_color
    @height = 200
    @setting = "./config/haarcascade_frontalface_alt2.xml"
  end

  def convert
    left = cut(save_path(@left), :left)
    right = cut(save_path(@right), :right)
    background = Image.new(right.columns + left.columns, @height)
    result = background.composite(right, NorthWestGravity, OverCompositeOp)
    result = result.composite(left, NorthEastGravity, OverCompositeOp)
    result.format = "JPEG"
    filename = Digest::SHA1.hexdigest(@left + @right +
                                      @left_color + @right_color)
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
      rect[0] = rect[0] + rect[2] / 2 if left_or_right.to_s == "left"
      rect[2] = rect[2] / 2 # half width
      image.crop(*rect)
    }.first
    result.resize!((result.columns.to_f * (@height / result.rows.to_f)).to_i,
                   @height)
    result.format = "JPEG"
    matte_pct = (left_or_right.to_s == "left") ? @left_color : @right_color
    result = result.colorize(0.5, 0.5, 0.5, matte_pct)
    result
  end
end
