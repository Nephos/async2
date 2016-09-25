require_relative "../async2"
require "socket"
require "net/http"
require "uri"

class Async2
  module HTTP

    BUFF_LEN = 4096
    private def read_all(io)
      buff = ""
      while (l = io.read_nonblock BUFF_LEN)
        buff += l
        break if l.size < BUFF_LEN
      end
      buff
    end

    private def to_response(buff, io = nil)
      split = buff.split("\r\n")
      first = split.first
      rep = Net::HTTPResponse.new first.split[0], Integer(first.split[1]), first.split[2]
      rep.instance_variable_set "@socket", io
      idx = split.index ""
      if idx
        headers = split[1 .. (idx - 1)]
        body = split[idx .. -1].join if idx < split.size - 1
        headers.each { |e| head = e.match(/([^:]+): (.+)/) ; rep[head[1]] = head[2] }
        rep.body = body
        return [rep, body]
      end
      return [rep, nil]
    end

    def get(uri, headers = {})
      request(uri, "GET", headers) do |body, res, buff|
        yield body, res, buff
      end
    end

    def request(uri, verb = "GET", headers = {}, body = nil)
      uri = URI.parse uri
      uri.path = "/" if uri.path == ""
      headers["User-Agent"] = "ruby/#{RUBY_VERSION}"
      headers["Host"] = uri.hostname
      headers["Accept"] = "*/*"
      buffer = "#{verb} #{uri.path} HTTP/1.1\r\n" + headers.map { |k, v| "#{k}: #{v}" }.join("\r\n") + "\r\n\r\n"
      buffer += "\r\n#{body}" if body
      socket = TCPSocket.new uri.hostname, uri.port
      p "client> #{buffer}"
      socket.print buffer
      Async2.instance.read(socket) do
        buff = read_all(socket)
        rep, body = to_response(buff, socket)
        yield body, rep, buff
      end
    end
  end

  include HTTP
end

if __FILE__ == $0

  # serv = TCPServer.new "0.0.0.0", 9999
  # Thread.new {
  #   sleep 0.1
  #   begin
  #     Async2.instance.get("http://127.0.0.1:9999") { |body, rep, buff|
  #       puts "client< BODY: #{body.inspect}, BUFF: #{buff.inspect}, REP: #{rep.inspect}" }
  #   rescue => err
  #     puts err, err.backtrace
  #   end
  # }
  # cli = serv.accept
  # Async2.instance.read(cli) {
  #   req = cli.read_nonblock 4096
  #   # p "server< #{req}"
  #   # p "server> HTTP/1.1 200 OK\r\n"
  #   cli.print "HTTP/1.1 200 OK\r\nTest: 1\r\n\r\nbodybodybody"
  # }
  # sleep 0.8

  Async2.instance.get("http://linuxfr.org") { |body, rep, buff|
    puts
    p "body: #{body.inspect}"
    p "rep: #{rep.inspect}"
    p "buff: #{buff.inspect}"
  }
  sleep 1
end
