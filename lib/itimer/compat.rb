require 'itimer'

module Timeout
  class Error < RuntimeError
  end

  def timeout(sec, klass=Error, &block)
    return Itimer.timeout(sec, klass, &block)
  end

  module_function :timeout
end
