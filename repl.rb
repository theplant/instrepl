require "drb"
require "erb"
require "readline"
require "timeout"

require "childprocess"

def instruments_script
  File.expand_path "repl.out.js"
end

def drb_address
  "druby://localhost:8788"
end

# write script to tmpfile
def generate_scriptfile

  script = File.read("repl.js.erb")
  result = ERB.new(script).result(binding)

  File.write(instruments_script, result)
end

# start instruments
def start_instruments app_path
  cmd = ["instruments", "-t",
         "/Applications/Xcode.app/Contents/Applications/Instruments.app/Contents/PlugIns/AutomationInstrument.bundle/Contents/Resources/Automation.tracetemplate",
         app_path, "-e", "UIARESULTSPATH", ".", "-e", "UIASCRIPT", instruments_script]

  process = ChildProcess.build(*cmd)
  process.io.inherit!
  at_exit {
    SERVER.request ":quit"
    begin
      process.poll_for_exit(10)
    rescue ChildProcess::TimeoutError
      process.stop # tries increasingly harsher methods to kill the process.
    end

  }
  process.start


end

# read line
def read
  line = Readline.readline("> ", true)
  line && line.strip
end

# eval isn't really a good name for a method...
def ev cmd
  SERVER.request cmd
end

class Server

  attr_accessor :queue

  def initialize
    @queue = []
    @thread = Thread.current
  end

  def request cmd
    @queue.push cmd
    wait_for_response
  rescue Timeout::Error
    puts "Timeout waiting for response from instruments."
  end

  def wait_for_response timeout = 10
    Timeout.timeout(timeout) do
      @thread = Thread.current
      Thread.stop
    end
  end

  def pop_command
    @queue.shift
  end

  def respond response
    puts " => #{response}"
    @thread.wakeup
  end

  def start drb_address
    DRb.start_service(drb_address, self)
  end
end

SERVER = Server.new

# read error from instruments

# send quit to instruments

# quit instruments

# remove temp file


generate_scriptfile
puts "Starting DRb server..."
SERVER.start drb_address
puts "Starting instruments..."
start_instruments ARGV[0]
SERVER.wait_for_response 20
puts "Starting REPL..."
loop {
  cmd = read
  if cmd
    ev cmd unless cmd.empty?
  else
    puts
    break
  end
}
