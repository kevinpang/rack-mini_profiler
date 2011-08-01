module Rack
  class MiniProfiler
    module Options
      @@inject_jquery = false
      @@jquery_path = "https://ajax.googleapis.com/ajax/libs/jquery/1.6.2/jquery.min.js"

      class << self
        def inject_jquery
          @@inject_jquery
        end

        def inject_jquery=(value)
          @@inject_jquery = value
        end

        def jquery_path
          @@jquery_path
        end

        def jquery_path=(value)
          @@jquery_path = value
        end
      end      
    end
  end
end