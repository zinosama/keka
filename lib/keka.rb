require 'keka/version'

module Keka

  class Halt < StandardError
    attr_reader :keka
    def initialize(keka)
      @keka = keka
      super
    end
  end

  class Base
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

  def self.err_if!(evaluator, msg = nil)
    raise Halt.new(err(msg)) if (evaluator.respond_to?(:ok?) ? evaluator.ok? : evaluator)
  end

  def self.err_unless!(evaluator, msg = nil)
    if evaluator.is_a? self::Base
      return if evaluator.ok?
      evaluator.msg = msg if msg
      raise Halt.new(evaluator)
    else
      raise Halt.new(err(msg)) unless evaluator
    end
  end

  def self.ok_if!(evaluator, msg = nil)
    if evaluator.is_a? self::Base
      return unless evaluator.ok?
      evaluator.msg = msg if msg
      raise Halt.new(evaluator)
    else
      raise Halt.new(ok(msg)) if evaluator
    end
  end

  def self.run
    raise 'Block required!' unless block_given?
    yield
    ok
  rescue Halt => e
    e.keka
  end


  # private (maybe)
  def self.ok(msg = nil)
    Base.new(true, msg)
  end

  # private (maybe)
  def self.err(msg = nil)
    Base.new(false, msg)
  end

end
