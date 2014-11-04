module Itimer
  require 'itimer_native'

  class Timeout < RuntimeError
  end

  def self.timeout(seconds, klass=Timeout)
    ret = nil

    prev_timeout = @active_timeout
    start = Time.now
    absolute_timeout = start + seconds

    if prev_timeout && absolute_timeout > prev_timeout
      # this timer is nested in another one that will timeout before it,
      # it will never fire
      ret = yield
    else
      @counter ||= 0
      @counter += 1

      catch_name = "itimer_#{@counter}"

      prev_handler = Signal.trap 'ALRM' do
        begin
          raise klass
        rescue klass
          throw(catch_name, $!)
        end
      end

      timed_out = true
      @active_timeout = absolute_timeout

      exception = catch(catch_name) do
        set(:real, seconds)
        begin
          ret = yield
          timed_out = false
        ensure
          @active_timeout = prev_timeout
          now = Time.now
          if prev_timeout && prev_timeout - now > 0
            set(:real, prev_timeout - now)
          else
            set(:real, 0)
          end

          Signal.trap('ALRM', prev_handler)
        end
      end

      if timed_out
        raise exception
      end
    end

    return ret
  end
end
