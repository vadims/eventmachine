# this error occurs when you have several sockets, like 3
# they are all 'closed' but their descriptors are in the middle of being collected
# THEN the program terminates, which causes the EM thread to jump to its finalizer.

$:.unshift File.dirname(__FILE__) + "/../lib"
require 'eventmachine'
require 'socket'
require 'test/unit'

module SlowClosers
  @@total_closed = 0

  def post_init
    @@total_closed += 1
    raise LocalJumpError.new() if @@total_closed == 2
  end

  def unbind
    @@total_closed += 1
    raise LocalJumpError.new() if @@total_closed == 2
  end

end

class TestHandlesUncaughtException < Test::Unit::TestCase

  def setup
    @server = TCPServer.new('localhost', 6000)
    @thread = Thread.new { a.accept }
    SlowClosers.class_eval("@@total_closed = 0")
  end
  def teardown
    @thread.kill
    @server.close
  end

  def test_ends_well_multi_thread # note that ideally it should try it with kqueue, epoll, and normal.  I'm not sure if all the tests should just be re-run with those settings or what
    begin
      passed = false
      EM::run {
        # print "here3\n"
        3.times {EM::connect '127.0.0.1', 6000, SlowClosers}
        # print "here5\n"
      }
    rescue LocalJumpError
      # we should get here--if it errs it will err with a 'HARD' c-style error
      # print "here2\n"
      passed = true
    rescue EventMachine::ConnectionNotBound => e
      puts e
      EM.run { EM.next_tick { EM.stop } }
    end
    # print "here\n"
    assert passed
  end

  # another test with possibility would be one that encourage the ConnectionUnbound caused if they
  # do a connection or add_timer or start_server from another thread.  Not sure if we want to care about that one [though we should, really].  

end