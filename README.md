# Instruments UIAutomation REPL

Running REPL:

```
ruby repl.rb <path to your iOS.app>
```

The REPL will start, and you can enter the same commands that you would enter in an Instruments UI Automation script.

# What can I do with it

FIXME: actually give some examples here.

You can execute any Javascript statement that you can write in an instruments script, such as:

```
target.frontMostApp().mainWindow().tabBar()[0].tap()
```

to tap on the first element in the app's tab bar.

# How does it work?

The REPL process:

1. Starts up a DRb server
2. Generates a Javascript file for Instruments that is described below
3. Pushes any commands into the DRb server's queue

The Instruments client is composed of two parts:

1. A simple script that will pop (it's not really LIFO) commands from the DRb server and print them out.

2. A (generated) Javascript file that loops the script and executes each command that is retrieved from the DRb server via `eval`

