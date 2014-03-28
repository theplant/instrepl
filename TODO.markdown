* Start `instruments` automatically in server process

* Print stdout/err of instruments in REPL process

* Sleep in client when no commands are available, so we don't need to
  be spinning when waiting for a command

* Choose random high open port for DRb server

* Write JS outfile to tmp file, and unlink file when server is up and
  running

* Refactor instruments JS file to reduce surface of adapter (push all
  code into something like a `_repl` object).
