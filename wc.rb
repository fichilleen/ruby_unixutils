#!/usr/bin/env ruby

require 'optparse'

def lineCount ( in_file )
    nls = 0
    in_file.each_char { |x| nls += 1 if x == "\n" }
    nls
end

def charCount ( in_file )
    chars = 0
    in_file.each_char { chars += 1 }
    chars
end

def byteCount ( in_file )
    bytes = 0
    in_file.each_byte { bytes += 1 }
    bytes
end

def getOptions
    options = {}
    OptionParser.new do |opts|
      opts.banner = "wc - print newline, word, and byte counts for each file"

      opts.on("-b", "--bytes", "Count bytes") do |b|
        options[:bytes] = b
      end

      opts.on("-c", "--chars", "Count characters") do |c|
        options[:chars] = c
      end

      opts.on("-l", "--lines", "Count lines") do |l|
        options[:lines] = l
      end

    end.parse!

    filename = ARGV.pop
    if filename.is_a? String
        options[:filename] = File.new( filename )
    elsif ! STDIN.tty?
            options [:filename] = $stdin 
    else
        puts filename
        raise "No filename passed, and nothing on stdin"
    end

    return options
end

opts = getOptions 

if opts [:bytes]
    puts byteCount opts[:filename]
elsif opts [:lines]
    puts lineCount opts[:filename]
elsif opts [:chars]
    puts charCount opts[:filename]
end

