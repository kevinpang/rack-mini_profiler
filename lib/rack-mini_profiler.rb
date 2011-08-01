require "rack-mini_profiler/options"
require "uuidtools"

module Rack
  class MiniProfiler
    def initialize(app)
      @app = app
    end
    
    def call(env)
      @env = env
      @original_request = Request.new(env)
      
      if load_result_request?
        result_id = Rack::Utils.parse_query(@original_request.path)["id"]
        result_json = load_result_json(result_id)
        return [200, {"Content-Length" => result_json.bytesize.to_s, "Content-Type" => "application/json"}, [result_json]]
      end
      
      start = Time.now
      @status, @headers, @response = @app.call(env)
      stop = Time.now
      @response_time = (100 * (stop - start)).round

      save_result
      @headers["X-Mini-Profiler-Id"] = @result_id if ajax_request?
      inject_html if initial_page_request?

      [@status, @headers, @response]
    end
    
    private
      def ajax_request?
        @env["HTTP_X_REQUESTED_WITH"] == "XMLHttpRequest"
      end
    
      def load_result_request?
        ajax_request? && @original_request.path =~ /mini-profiler-results/
      end
    
      def initial_page_request?
        !ajax_request? && html_response?
      end
    
      def html_response?
        @headers && @headers["Content-Type"].include?("text/html")
      end

      def inject_html
        code = ""
        code << %Q{<ol id="mini_profiler_results"></ol>}
        code << %Q{<style type="text/css">#{read_public_file("mini_profiler.css")}</style>\n}
        code << %Q{<script type="text/javascript" src="#{Options.jquery_path}"></script>\n"} if Options.inject_jquery
        code << %Q{<script type="text/javascript">#{read_public_file("mini_profiler.js")}</script>\n}
        code << %Q{
          <script type="text/javascript">
            MiniProfiler.showButton(#{load_result_json(@result_id)}, false);
          </script>
        }
      
        @response.first.gsub!("</body>", "#{code}</body>")
        @headers["Content-Length"] = @response.first.bytesize.to_s
      end
    
      def read_public_file(file)
        output = ::File.open(::File.join(::File.dirname(__FILE__), "rack-mini_profiler", "public", file), "r:UTF-8") do |f|
          f.read
        end
      end
    
      def save_result
        @result_id = UUIDTools::UUID.random_create.to_s
        Rails.cache.write(@result_id, @response_time)
      end
    
      def load_result_json(result_id)
        response_time = Rails.cache.read(result_id)
      
        %Q{
          {
            "response_time": #{@response_time}
          }
        }
      end
  end
end
