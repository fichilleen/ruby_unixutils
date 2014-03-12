#!/usr/bin/env ruby

require 'optparse'
require 'open3'

class ParallelExecution
    def run ( input, cmd, replace = false, verbose = false )
        if verbose
            $stderr.puts cmd
        end
        if replace
            @cmd = cmd.sub "{}", input
        else
            @cmd = "#{cmd} #{input}"
        end
        handleCall
    end

    def handleCall
        stdin, stdout, stderr, wait_thr = Open3.popen3( @cmd )
        stdin.close
        @pid = wait_thr[:pid]

        stdout.each_line { |x| puts x } 
        stderr.each_line { |x| $stderr.puts x } 

        stdout.close
        stderr.close
        @exit_status = wait_thr.value
    end
end

def getOptions
    options = {}
    OptionParser.new do |opts|
      opts.banner = "xargs - build and execute command lines from standard input"

      opts.on("-0", "Seperate by null character") do |null|
        options[:null] = null
      end

      opts.on("-i", "-I",
            "Replace {} with args, instead of default suffix") do |r|
        options[:replace] = r
      end

      opts.on("-v", "--verbose", 
              "Print the command on stderr before executing it.") do |v|
        options[:verbose] = v
      end

    end.parse!

    if options[:null]
        split_by = "\0"
    else
        split_by = /\s/
    end
    options[:inputs] = $stdin.read.split split_by

    options[:cmd] = ARGV.join ( " " )

    return options
end

opts = getOptions 

puts opts
threads = []

opts[:inputs].each do |input| 
    threads << Thread.new { ParallelExecution.new.run input, opts[:cmd], opts[:replace], opts[:verbose] }
end

threads.each { |thread| thread.join }


