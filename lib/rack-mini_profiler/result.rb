require "uuidtools"

module Rack
  class MiniProfiler
    class Result
      attr_accessor :response_time
      attr_reader :id
      
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