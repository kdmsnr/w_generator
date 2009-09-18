require 'lib/converter.rb'
require 'app.rb'

c = Converter.new(
                  "http://wota.jp/ac/images/rails/opencv/61/c-airi3697.jpg",
                  "http://wota.jp/ac/images/rails/opencv/61/c-airi3697.jpg"
                  )


#c = Converter.new("left.jpg", "right.jpg")
c.convert
