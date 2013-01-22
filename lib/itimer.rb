module Itimer
  require 'itimer_native'

  class Timeout < RuntimeError
  end

  def self.timeout(seconds, klass=Timeout)
    Signal.trap 'ALRM' do
      raise klass
    end

    begin
      set(:real, seconds)
      ret = yield
    ensure
      set(:real, 0)
    end

    return ret
  end
end
