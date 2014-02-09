require "drb"
require "erb"
require "readline"
require "timeout"

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
def start_instruments
  cmd = %|/Applications/Xcode.app/Contents/Developer/usr/bin/instruments -D /Users/bodhi/Code/work/theplant/QortexiOS/integration/tmp/trace -t /Applications/Xcode.app/Contents/Applications/Instruments.app/Contents/PlugIns/AutomationInstrument.bundle/Contents/Resources/Automation.tracetemplate "/Users/bodhi/Code/work/theplant/QortexiOS/build/iphonesimulator/Qortex (Dev).app" -v -e UIASCRIPT #{instruments_script} -e UIARESULTSPATH /Users/bodhi/Code/work/theplant/QortexiOS/integration/tmp/results|
        # do it manually
        puts cmd
end

# read line
def read
  Readline.readline("> ", true).strip
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
    Timeout.timeout(10) do
      @thread = Thread.current
      Thread.stop
    end
  rescue Timeout::Error
    puts "Timeout waiting for response from instruments."
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
SERVER.start drb_address
start_instruments
loop {
  cmd = read
  if cmd
    ev cmd unless cmd.empty?
  else
    puts
    break
  end
}
