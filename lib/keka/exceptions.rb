module Keka
  class Halt < StandardError
    attr_reader :result
    def initialize(result)
      @result = result
      super
    end
  end
end
