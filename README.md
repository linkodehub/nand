# Nand

### Overview

Nand is a simple CLI tool to make anything daemon by Ruby.
Nand is the meaning of Nandemo of Japanese.

Nandemo of here is a executable file and shell command, a non-executable Ruby file.

For starting daemonize TARGET, You can just type `nand start TARGET`.
You can stop by `nand stop TARGET`. `nand status TARGET` show it running status.

## Installation

Add this line to your application's Gemfile:

    gem 'nand'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nand

## Easy Usage

### Command Definition

	$ nand SUB_COMMAND TARGET [OPTION]

### Start

	$ cd /any/path
	$ nand start sleep 1000
	sleep is Start Success [85596]

You can start TARGET by `start` SUB_COMMAND.
Though OPTION(s) after TARGET is Nand option, OPTION(s) Nand is unknown,
will be handed over to TARGET.
Here `1000` is handed over to `sleep`. 
And Nand recognizes a shell command `sleep` as TARGET name.
When TARGET is success to be a daemon process, Nand show TARGET namd and daemon
process id.

### Status

For the TARGET `sleep` running status, Nand `status` command show running status.

	$ cd /any/path
	$ nand status sleep
	sleep is Running [85596] by USER in /any/path

You can omit the TARGET name `sleep` because you stay in `/any/path`.

### Stop

Nand `stop` command stop daemon process with TARGET name.

	$ nand stop sleep
	sleep is Stopped [85596]
	$ nand status sleep
	sleep is Not Running in /any/path

You can also omit the TARGET name `sleep` as `status` because you stay in `/any/path`.

## A Ruby File

Following `forever_sleep.rb` in current directory, you can make it daemon with
file name as TARGET name.

```ruby:forever_sleep.rb
require 'nand/plugin'

module Sample
  class ForeverSleep
    extend Plugin
    def self.executor(*argv)
      new(*argv)
    end
    def exec
      sleep
    end
  end
end
```

	$ nand start forever_sleep.rb -p Sample::ForeverSleep
	forever_sleep.rb is Start Success [86326]

	$ nand stop forever_sleep.rb
	forever_sleep.rb is Stopped [86326]

Nand can find the executor with exec method from defined class by `-p` option.
The class need to extend `Nand::Plugin`.
Then then executor can become a daemon process as TARGET name `forever_sleep.rb`.

## More Usage

### Avoid duplicated Nand Options

There are two ways to avoid duplicated Nand options for daemon's process options.

First, the options can be enclosed in "(double) or '(single) quatations.

	$ nand start any.sh "--run_dir /tmp"


Others, you can put them after double dash(--).

	$ nand start any.sh -- --run_dir /tmp

### Pipes to Daemon Process

You can pipe to daemon process STDOUT and STDERR, STDIN by using Nand options
`--out` and `--err`, `--in`.

Here is `sleep_echo.sh` as follows:

```sh
#!/bin/sh
sleep $1
echo $2
```
Then you can start with Nand pipe option.

	$ nand start sleep_echo.sh 100 '"foo bar baz"' --out out.log
	
	$ cat out.log
	foo bar baz

### Running Directory

It is very important that you define the running directory with Nand option `--run_dir`.
A PID file is put in the running directory and daemon process change the running directory.
If you don't define the running directory, it is the current directory.

	$ nand start sleep_echo.sh 100 abc --run_dir /tmp --out out.log

### Prohibition of Duplicated Start

Basically, you can not start duplicated daemon process name.

	$ nand start sleep 1000
	sleep is Start Success [97649]
	$ nand start sleep 1000
	sleep is Start Failed [PID file exist /any/path/.nand_sleep.pid]

If you would like to start duplicated daemon process name, you can
start in another run directory or as another daemon process name.

	$ nand start sleep 1000 --run_dir /tmp
	sleep1 is Start Success [97611]
	$ nand start sleep 1000 -n sleep1
	sleep1 is Start Success [97649]
	$ nand status -a
	sleep is Running [97649] by USER in /run/dir
	sleep1 is Running [97765] by USER in /run/dir
	sleep is Running [97611] by USER in /tmp

### Automatically Stop

Daemon process can automatically stop at the time limit, you defined.

	$ nand start vmstat 5 --sec 600

Then `vmstat` will automatically stop after the lapse of 600 seconds.

### Automatically Recovery

If you defined Nand `-r` option, when the daemon process downed,
it would restart.

	$ nand start sleep 100 -r

This `sleep 100` will be down after 100 seconds, then `sleep 100`
will restart soon.


## Note

When `nand stop`, Nand send signal(SIGTERM) to daemon process group, and
wait for termination of daemon process. Your daemon process finish by receiving
a SIGTERM.

You must not remove a PID file for Nand `.nand_[DAEMON_NAME].pid`.
It has be required to confirm integrity.
If you removed it, Nand output an error. Then you need to stop
the daemon process manually.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

MIT
