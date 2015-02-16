require "nand/version"

module Nand
  def wrap_exception
    yield
  rescue => e
    STDERR.puts e.message
    #STDERR.puts "\n\t" + e.backtrace.join("\n\t")
    exit -1
  end
  def self.additional_argv=(argv)
    @@additional_argv ||= argv.freeze
  end
  def self.additional_argv
    @@additional_argv
  end
  def string_to_stdio( str )
    if str.to_s.upcase =~/^STD(OUT|ERR|IN)$/
      eval(str)
    else
      str
    end
  end
  def restore_options( options )
    opts = options.dup
    unless opts[:debug]
      opts[:out] &&= string_to_stdio(opts[:out])
      opts[:err] &&= string_to_stdio(opts[:err])
      opts[:in]  &&= string_to_stdio(opts[:in] )

      opts[:daemon_log] &&= string_to_stdio(opts[:daemon_log])
      opts[:daemon_out] &&= string_to_stdio(opts[:daemon_out])
      opts[:daemon_err] &&= string_to_stdio(opts[:daemon_err])

    else
      opts[:out] = STDOUT
      opts[:err] = STDERR

      opts[:daemon_out] = STDOUT
      opts[:daemon_err] = STDERR
      opts[:daemon_log] = STDOUT
    end
    opts
  end
end

include Nand
