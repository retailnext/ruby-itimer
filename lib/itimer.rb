module Itimer
  require 'itimer_native'

  class Timeout < RuntimeError
  end

  def self.timeout(seconds, klass=Timeout)
    @counter ||= 0
    @counter += 1

    catch_name = "itimer_#{@counter}"

    prev_handler = Signal.trap 'ALRM' do
      throw catch_name
    end

    prev = get(:real)
    start = Time.now
    if prev > 0
      seconds = [prev, seconds].min
    end

    timed_out = true

    catch catch_name do
      set(:real, seconds)
      begin
        ret = yield
        timed_out = false
      ensure
        if prev > 0
          set(:real, [prev - (Time.now-start), 0.01].max)
        else
          set(:real, 0)
        end

        Signal.trap('ALRM', prev_handler)
      end
    end

    if timed_out
      raise klass
    end

    return ret
  end
end
