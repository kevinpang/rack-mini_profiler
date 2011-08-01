require "uuidtools"

module Rack
  class MiniProfiler
    class Result
      attr_accessor :response_time, :url
      attr_reader :id
      
      def initialize
        @id = UUIDTools::UUID.random_create.to_s
      end
      
      def to_json
        %Q{
          {
            "id": "#{@id}",
            "response_time": #{@response_time},
            "url": "#{url}"
          }
        }
      end
    end
  end
end