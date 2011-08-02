require "rack/mini_profiler/options"
require "rack/mini_profiler/result"

module Rack
  class MiniProfiler
    def initialize(app)
      @app = app
    end
    
    def call(env)
      @env = env
      
      return load_result_response if load_result_request?
      
      @start = Time.now
      @status, @headers, @response = @app.call(env)
      @stop = Time.now

      save_result
      
      if initial_page_request?
        inject_html
      elsif ajax_request?
        inject_header
      end

      [@status, @headers, @response]
    end
    
    private
      def load_result_request?
        ajax_request? && @env["PATH_INFO"] =~ /mini-profiler-results/
      end
      
      def ajax_request?
        @env["HTTP_X_REQUESTED_WITH"] == "XMLHttpRequest"
      end
    
      def initial_page_request?
        !ajax_request? && html_response?
      end
    
      def html_response?
        @headers && @headers["Content-Type"].include?("text/html")
      end
      
      def save_result
        @result = Result.new()
        @result.response_time = (100 * (@stop - @start)).round
        @result.url = @env["SERVER_NAME"] + @env["SCRIPT_NAME"] + @env["PATH_INFO"] + "?" + @env["QUERY_STRING"]
        Rails.cache.write(@result.id, @result)
      end
      
      def load_result_response
        result_id = @env["QUERY_STRING"].gsub(/id=/, "")
        result = Rails.cache.read(result_id)
        result_json = result.to_json
        [200, {"Content-Length" => result_json.bytesize.to_s, "Content-Type" => "application/json"}, [result_json]]
      end

      def inject_html
        code = ""
        code << %Q{<ol id="mini_profiler_results"></ol>}
        code << %Q{<style type="text/css">#{read_public_file("mini_profiler.css")}</style>\n}
        code << %Q{<script type="text/javascript" src="#{Options.jquery_path}"></script>\n"} if Options.inject_jquery
        code << %Q{<script type="text/javascript">#{read_public_file("mini_profiler.js")}</script>\n}.gsub(/http:\/\/localhost:3000/, @env["SERVER_NAME"] + @env["SCRIPT_NAME"])
        code << %Q{
          <script type="text/javascript">
            MiniProfiler.showButton(#{@result.to_json}, false);
          </script>
        }
      
        @response.first.gsub!("</body>", "#{code}</body>")
        @headers["Content-Length"] = @response.first.bytesize.to_s
      end
      
      # Javascript code in mini_profiler.js intercepts AJAX responses, checks for this header, and if found fires off another
      # AJAX request to retrieve the result by the id specified.
      def inject_header
        @headers["X-Mini-Profiler-Id"] = @result.id
      end
    
      def read_public_file(filename)
        output = ::File.open(::File.join(::File.dirname(__FILE__), "mini_profiler", "public", filename), "r:UTF-8") do |f|
          f.read
        end
      end
  end
end
