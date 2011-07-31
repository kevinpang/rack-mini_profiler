require "rack-mini_profiler/options"
require "uuidtools"

module Rack
  class MiniProfiler
    VERSION = "0.0.1"
    
    def initialize(app)
      @app = app
    end
    
    def call(env)
      @env = env
      @original_request = Request.new(env)
      
      # headers = env.select {|k,v| k.start_with? 'HTTP_'}
      #     .collect {|pair| [pair[0].sub(/^HTTP_/, ''), pair[1]]}
      #     .collect {|pair| pair.join(": ") << "<br>"}
      #     .sort
      #     
      # puts headers
      
      return load_profiler_results if load_profiler_results_request?
      
      start = Time.now
      @status, @headers, @response = @app.call(env)
      stop = Time.now
      @response_time = (100 * (stop - start)).round

      save_profiler_results if ajax_request?
      inject_profiler_html if !ajax_request? && html_response?

      [@status, @headers, @response]
    end
    
    private
      def ajax_request?
        @env["HTTP_X_REQUESTED_WITH"] == "XMLHttpRequest"
      end
    
      def load_profiler_results_request?
        ajax_request? && @original_request.path =~ /mini-profiler-results/
      end
    
      def html_response?
        @headers && @headers["Content-Type"].include?("text/html")
      end

      # Injects profiler HTML into the initial page response
      def inject_profiler_html
        code = ""
        code << %Q{<style type="text/css">#{read_public_file("mini_profiler.css")}</style>\n}
        code << %Q{<script type="text/javascript" src="#{Options.jquery_path}"></script>\n"} if Options.inject_jquery
        code << %Q{<script type="text/javascript">#{read_public_file("mini_profiler.js")}</script>\n}
        code << %Q{
          <ol id="mini_profiler_results">
            <li>#{@response_time} ms</li>
          </ol>
        }
      
        @response.first.gsub!("</body>", "#{code}</body>")
        @headers["Content-Length"] = @response.first.bytesize.to_s
      end
    
      def read_public_file(file)
        output = ::File.open(::File.join(::File.dirname(__FILE__), "rack-mini_profiler", "public", file), "r:UTF-8") do |f|
          f.read
        end
      end
    
      # This routine is called whenever an AJAX request is made by the browser.
      #
      # Since we don't have the ability to modify the original page at this point, we save the profiler data off to the Rails cache
      # and pass back an id in the response headers. The js code in mini_profiler.js intercepts all AJAX responses and checks for
      # this response header. If found, it fires off another AJAX request to load the profiler data.
      def save_profiler_results
        id = UUIDTools::UUID.random_create.to_s
        Rails.cache.write(id, @response_time)
        @headers["X-Mini-Profiler-Id"] = id
      end
    
      def load_profiler_results
        id = Rack::Utils.parse_query(@original_request.path)["id"]
        response_time = Rails.cache.read(id)
      
        response_body = %Q{
          {
            "response_time": #{@response_time}
          }
        }
        
        [200, {"Content-Length" => response_body.bytesize.to_s, "Content-Type" => "application/json"}, [response_body]]
      end
  end
end
