module Rack
  class MiniProfiler
    module Options
      @@inject_jquery = false
      @@inject_jquery_tmpl = true

      class << self
        def inject_jquery
          @@inject_jquery
        end

        def inject_jquery=(value)
          @@inject_jquery = value
        end

        def inject_jquery_tmpl
          @@inject_jquery_tmpl
        end
        
        def inject_jquery_tmpl=(value)
          @@inject_jquery_tmpl = value
        end
      end      
    end
  end
end