#!/usr/bin/env ruby

require_relative '../../lib/parsedecision'
#require "debugger"

parser = ParseDecision::Parser.new

#debugger
parser.parse 'spec/data/wf-decision.txt', 'tmp/spec'

1.upto(5) do |i|
  puts "#{i}. Infinity, the star that would not die"
end
