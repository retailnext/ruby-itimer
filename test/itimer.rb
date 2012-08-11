require 'itimer'
require 'test/unit'

class ItimerTest < Test::Unit::TestCase
  def test_itimer
    Signal.trap 'ALRM' do
      raise Exception.new('ALRM')
    end

    Signal.trap 'VTALRM' do
      raise Exception.new('VTALRM')
    end

    Signal.trap 'PROF' do
      raise Exception.new('PROF')
    end

    assert_equal( 0, Itimer.get(:real) )
    assert_equal( 0, Itimer.get(:virtual) )
    assert_equal( 0, Itimer.get(:prof) )

    assert_equal( 0, Itimer.get_interval(:real) )
    assert_equal( 0, Itimer.get_interval(:virtual) )
    assert_equal( 0, Itimer.get_interval(:prof) )

    Itimer.set(:real, 5)
    Itimer.set(:virtual, 4)
    Itimer.set(:prof, 0.5)

    sleep 0.5
    assert_in_delta( 4.5, Itimer.get(:real), 0.01 )
    assert_in_delta( 4, Itimer.get(:virtual), 0.01 )
    assert_in_delta( 0.5, Itimer.get(:prof), 0.01 )

    assert_raises( Errno::EINVAL) { Itimer.set(:real, 2**32) }

    Itimer.set(:real, 0)
    Itimer.set(:virtual, 0)
    Itimer.set(:prof, 0)

    wait_for_sig = lambda do
      signal = nil
      begin
        sleep 2
      rescue Exception
        signal = $!.message
      end

      signal
    end

    start = Time.now
    Itimer.set(:real, 1)
    assert_equal( 'ALRM', wait_for_sig.call )
    assert_in_delta( Time.now-start, 1, 0.1 )

    start = Time.now
    Itimer.set_interval(:real, 1)
    Itimer.set(:real, 0.5)
    assert_equal( 'ALRM', wait_for_sig.call )
    assert_in_delta( Time.now-start, 0.5, 0.1 )

    start = Time.now
    assert_equal( 'ALRM', wait_for_sig.call )
    assert_in_delta( Time.now-start, 1, 0.1 )
    Itimer.set_interval(:real, 0)
  end
end
