require "drb"

drb_address = ARGV.shift

# DRb.start_service

server = DRbObject.new_with_uri(drb_address)

cmd = ARGV.shift

if cmd == "request"
  op = server.pop_command
  if op == ":quit"
    server.respond "quitting instruments..."
    exit(1) 
  end
  puts op
elsif cmd == "respond"
  server.respond  ARGV.join(" ")
else
  puts "unknown command"
end
