require "uuidtools"

module Rack
  class MiniProfiler
    class Result
      attr_accessor :response_time, :url, :ajax_result
      attr_reader :id
      
      def initialize
        @id = UUIDTools::UUID.random_create.to_s
      end
      
      def to_json
        %Q{
          {
            "id": "#{@id}",
            "response_time": #{@response_time},
            "url": "#{url}",
            "ajax_result": #{ajax_result ? true : false}
          }
        }
      end
    end
  end
end