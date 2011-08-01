require "rack-mini_profiler/options"
require "rack-mini_profiler/result"

module Rack
  class MiniProfiler
    def initialize(app)
      @app = app
    end
    
    def call(env)
      @env = env
      @original_request = Request.new(@env)
      
      return load_result if load_result_request?
      
      @start = Time.now
      @status, @headers, @response = @app.call(env)
      @stop = Time.now

      save_result
      inject_html if initial_page_request?

      [@status, @headers, @response]
    end
    
    private
      def load_result_request?
        ajax_request? && @original_request.path =~ /mini-profiler-results/
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

        Rails.cache.write(@result.id, @result)
        @headers["X-Mini-Profiler-Id"] = @result.id if ajax_request?
      end
      
      def load_result
        result_id = @original_request.params["id"]
        result = Rails.cache.read(result_id)
        result_json = result.to_json
        [200, {"Content-Length" => result_json.bytesize.to_s, "Content-Type" => "application/json"}, [result_json]]
      end

      def inject_html
        code = ""
        code << %Q{<ol id="mini_profiler_results"></ol>}
        code << %Q{<style type="text/css">#{read_public_file("mini_profiler.css")}</style>\n}
        code << %Q{<script type="text/javascript" src="#{Options.jquery_path}"></script>\n"} if Options.inject_jquery
        code << %Q{<script type="text/javascript">#{read_public_file("mini_profiler.js")}</script>\n}
        code << %Q{
          <script type="text/javascript">
            MiniProfiler.showButton(#{@result.to_json}, false);
          </script>
        }
      
        @response.first.gsub!("</body>", "#{code}</body>")
        @headers["Content-Length"] = @response.first.bytesize.to_s
      end
    
      def read_public_file(filename)
        output = ::File.open(::File.join(::File.dirname(__FILE__), "rack-mini_profiler", "public", filename), "r:UTF-8") do |f|
          f.read
        end
      end
  end
end
