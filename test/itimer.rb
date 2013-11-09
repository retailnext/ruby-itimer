require 'itimer'
require 'test/unit'
require 'itimer/compat'

class ItimerTest < Test::Unit::TestCase
  def teardown
    assert_equal( 0, Itimer.get(:real) )
    assert_equal( 0, Itimer.get(:virtual) )
    assert_equal( 0, Itimer.get(:prof) )
  end

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
    assert_in_delta( 4.5, Itimer.get(:real), 0.1 )
    assert_in_delta( 4, Itimer.get(:virtual), 0.1 )
    assert_in_delta( 0.5, Itimer.get(:prof), 0.1 )

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
    Itimer.set_interval(:real, 1.2)
    Itimer.set(:real, 0.5)
    assert_in_delta( 1.2, Itimer.get_interval(:real), 0.1 )
    assert_equal( 'ALRM', wait_for_sig.call )
    assert_in_delta( Time.now-start, 0.5, 0.1 )
    assert_in_delta( Itimer.get(:real), 1.2, 0.1 )

    start = Time.now
    assert_equal( 'ALRM', wait_for_sig.call )
    assert_in_delta( Time.now-start, 1.2, 0.1 )
    Itimer.set_interval(:real, 0)
    Itimer.set(:real, 0)
  end

  def test_timeout
    start = Time.now
    assert_raises( Itimer::Timeout ) do
      Itimer.timeout(1) { sleep 5 }
    end
    assert_in_delta( Time.now-start, 1, 0.1 )

    start = Time.now
    assert_raises( RuntimeError ) do
      Itimer.timeout(0.25, RuntimeError) { sleep 5 }
    end
    assert_in_delta( Time.now-start, 0.25, 0.1 )

    # nesting
    start = Time.now
    assert_raise( Itimer::Timeout ) do
      Itimer.timeout(0.25) do
        Itimer.timeout(0.5) do
          sleep 6
        end
      end
    end

    start = Time.now
    assert_raise( RuntimeError ) do
      Itimer.timeout(0.25) do
        Itimer.timeout(0.1, RuntimeError) do
          sleep 1
        end
      end
    end
    assert_in_delta( Time.now-start, 0.1, 0.1 )
  end

  def test_nested_timeouts_inner_rescue
    start = Time.now
    timeouts = false
    assert_raise( Itimer::Timeout ) do
      Itimer.timeout(0.25) do
        begin
          Itimer.timeout(0.1) do
            sleep 1
          end
        rescue Itimer::Timeout
          timeouts = true
        end
        sleep 1
      end
    end
    assert( timeouts )
    assert_in_delta( Time.now-start, 0.25, 0.1 )
  end

  def test_nested_timeouts_larger_inner

    start = Time.now
    timeouts = false
    assert_raise( Itimer::Timeout ) do
      Itimer.timeout(0.25) do
        begin
          Itimer.timeout(3) do
            sleep 1
          end
        rescue Itimer::Timeout
          timeouts = true
        end
        sleep 1
      end
    end
    assert( timeouts )
    assert_in_delta( Time.now-start, 0.25, 0.1 )
  end

  def test_compat
    start = Time.now
    assert_raises( Timeout::Error ) do
      Timeout::timeout(0.25) { sleep 5 }
    end
    assert_in_delta( Time.now-start, 0.25, 0.1 )
  end

  def test_exception
    start = Time.now
    assert_raises( ArgumentError ) do
      Itimer.timeout(1) { raise ArgumentError }
    end
    assert_in_delta( Time.now-start, 0, 0.1 )

    assert_equal( 0, Itimer.get(:real) )
  end
end
