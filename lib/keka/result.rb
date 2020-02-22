module Keka
  class Result
    attr_accessor :msg

    def initialize(is_success, msg)
      @is_success = is_success
      @msg = msg
    end

    def ok?
      is_success
    end

    private
    attr_reader :is_success
  end
end
