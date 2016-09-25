require "singleton"
require_relative "async2/http"

class Async2
  include Singleton
  attr_accessor :wait

  def initialize wait = 0.01
    @wait = wait
    @read = {}
    @write = {}
    @t = Thread.new do
      loop do
        begin
          read, write = IO.select @read.keys, @write.keys, nil, 0
          read&.each { |io| @read[io].call(io); @read.delete io }
          write&.each { |io| @write[io].call(io); @write.delete io }
          sleep wait unless read || write
        rescue => err
          STDERR.puts err, err.backtrace
          raise
          retry
        end
      end
    end
  end

  def read(io, &b)
    @read[io] = b
  end

  def write(io, &b)
    @write[io] = b
  end
end

# if __FILE__ == $0
#   puts "First test"
#   f = File.open "/tmp/a", "r"
#   Async2.instance.read(f) { |io| STDERR.puts "1 It worked:"; STDERR.puts io.gets }
#   puts "sleep 1"
#   sleep 1
#   puts "Second test"
#   require "socket"
#   s = TCPServer.new "0.0.0.0", 9999
#   Thread.new {
#     sleep 0.5
#     io = TCPSocket.new("127.0.0.1", 9999)
#     sleep 0.5
#     io.puts "mdr"
#   }
#   f = s.accept
#   Async2.instance.read(f) { |io| STDERR.puts "2 It worked:"; STDERR.puts io.gets }
#   puts "sleep 1"
#   sleep 2
# end
