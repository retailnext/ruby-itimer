module Itimer
  require 'itimer_native'

  class Timeout < RuntimeError
  end

  def self.timeout(seconds, klass=Timeout)
    Signal.trap 'ALRM' do
      raise klass
    end

    prev = get(:real)
    start = Time.now
    if prev > 0
      seconds = [prev, seconds].min
    end

    begin
      set(:real, seconds)
      ret = yield
    ensure
      if prev > 0
        set(:real, [prev - (Time.now-start), 0.01].max)
      else
        set(:real, 0)
      end
    end

    return ret
  end
end
