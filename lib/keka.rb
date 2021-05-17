require 'keka/version'
require 'keka/exceptions'
require 'keka/result'
require 'keka/context'

module Keka
  class << self
    include Context::Originable

    def err_if!(evaluator, msg = nil, &block)
      if (evaluator.respond_to?(:ok?) ? evaluator.ok? : evaluator)
        if msg
          raise Halt.new(err_result(msg))
        elsif block_given?
          message = yield block
          raise Halt.new(err_result(message))
        else
          raise Halt.new(err_result)
        end
      end
    end

    def err_unless!(evaluator, msg = nil, &block)
      if evaluator.is_a? self::Result
        return if evaluator.ok?
        if msg
          evaluator.msg = msg
        else
          evaluator.msg = yield block if block_given?
        end
        raise Halt.new(evaluator)
      else
        unless evaluator
          error_result = \
            if msg
              err_result(msg)
            else
              message = yield block if block_given?
              err_result(message)
            end
          raise Halt.new(error_result)
        end
      end
    end

    def ok_if!(evaluator, msg = nil)
      if evaluator.is_a? self::Result
        return unless evaluator.ok?
        evaluator.msg = msg if msg
        raise Halt.new(evaluator)
      else
        raise Halt.new(ok_result(msg)) if evaluator
      end
    end

    def err!(msg = nil)
      raise Halt.new(err_result(msg))
    end

    def ok!(msg = nil)
      raise Halt.new(ok_result(msg))
    end

    # private (maybe)
    def ok_result(msg = nil)
      Result.new(true, msg)
    end

    # private (maybe)
    def err_result(msg = nil)
      Result.new(false, msg)
    end
  end
end
