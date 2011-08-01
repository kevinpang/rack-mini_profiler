require "uuidtools"

module Rack
  class MiniProfiler
    class Result
      attr_accessor :id, :response_time
      
      def initialize
        @id = UUIDTools::UUID.random_create.to_s
      end
      
      def to_json
        %Q{
          {
            "response_time": #{@response_time}
          }
        }
      end
    end
  end
end