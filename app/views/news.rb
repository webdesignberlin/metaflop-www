#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

require './app/views/layout'

class App < Sinatra::Base
  module Views
    class News < Layout
      def page_title
        'Hello World'
      end

      # randomly create a sequence of 12 images,
      # varying by language, keeping the order
      def images
        files = Dir['assets/images/helloworld/*']

        %w(adjuster bespoke fetamont).map do |font_family|
          (1..12).map do |i|
            files.select { |x|
              x =~ /#{"%s-helloworld-%02d-" % [font_family, i]}/
            }.sample
          end
        end.flatten.map { |image|
          image_path(image.sub(/assets\/images\//, ''))
        }.shuffle
      end
    end
  end
end
