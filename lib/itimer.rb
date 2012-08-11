module Itimer
  require 'itimer_native'

  class Timeout < RuntimeError
  end

  def self.timeout(seconds, klass=Timeout)
    Signal.trap 'ALRM' do
      raise klass
    end

    set(:real, seconds)
    ret = yield
    set(:real, 0)

    return ret
  end
end
