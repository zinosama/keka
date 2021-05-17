module Keka
  class Result
    def initialize(is_success, msg_or_errors)
      @is_success = is_success
      @msg_or_errors = msg_or_errors
    end

    def ok?
      is_success
    end

    def msg=(msg_or_errors, &block)
      @msg_or_errors = msg_or_errors
    end

    def msg
      return @msg_or_errors if @msg_or_errors.is_a?(String)
      return @msg_or_errors.full_messages.join(', ') if active_model_error?
      return yield @msg_or_errors if block_given? && is_success

      @msg_or_errors
    end

    def errors
      return {} if ok?
      return {base: [@msg_or_errors]} if @msg_or_errors.is_a?(String)
      return @msg_or_errors.messages if active_model_error?
      return yield @msg_or_errors if block_given? && is_success

      {}
    end

    private
    attr_reader :is_success

    def active_model_error?
      Object.const_defined?("ActiveModel") &&
        @msg_or_errors.is_a?(ActiveModel::Errors)
    end
  end
end
