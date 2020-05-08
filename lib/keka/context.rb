module Keka
  class Context

    module Originable
      def rescue_with(err_class, err_msg = nil)
        Context.new.rescue_with(err_class, err_msg)
      end

      def run(&block)
        Context.new.run(&block)
      end
    end

    def initialize
      @opts = {
        rescue_exceptions: []
      }
    end

    def rescue_with(err_class, err_msg = nil)
      opts[:rescue_exceptions] << {
        klass: err_class,
        msg:   err_msg
      }
      self
    end

    def run
      raise 'Block required!' unless block_given?
      yield
      Keka.ok_result
    rescue Keka::Halt => e
      e.result
    rescue StandardError => e
      raise unless matched = opts[:rescue_exceptions].detect { |setting| e.is_a?(setting[:klass]) }
      Keka.err_result(matched[:msg])
    end

    private
    attr_reader :opts

  end
end
