module Keka
  class Result
    attr_writer :msg

    def initialize(is_success, msg)
      @is_success = is_success
      @msg = msg
    end

    def ok?
      is_success
    end

    def msg
      return @msg if @msg.is_a?(String)
      return @msg.full_messages.join(', ') if active_model_error?

      @msg
    end

    def errors
      return {} if ok?
      return {base: [@msg]} if @msg.is_a?(String)
      return @msg.messages if active_model_error?

      {}
    end

    private
    attr_reader :is_success

    def active_model_error?
      Object.const_defined?("ActiveModel") &&
        @msg.is_a?(ActiveModel::Errors)
    end
  end
end
