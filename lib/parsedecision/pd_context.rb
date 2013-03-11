##############################################################################
# File:: pd_context.rb
# Purpose:: Context object used by all plugins
#
# Author::    Jeff McAffee 03/12/2010
# Copyright:: Copyright (c) 2010, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'ktcommon/ktpath'
require 'ktcommon/ktcmdline'
require 'parsedecision/plugin'
require 'pathname'

      #$LOG.level = Logger::ERROR

##############################################################################
# Everything is contained in Module ParseDecision
module ParseDecision

  ##########################################################################
  # Context class holds all info and state about the current parsing process
  class PDContext

    attr_reader :outdir
    attr_reader :srcdir
    attr_reader :file
    attr_reader :verbose
    attr_reader :index
    attr_reader :state
    attr_reader :parseMode


    def initialize()
        $LOG.debug "PDContext::initialize"
      @outdir   = nil
      @srcdir   = "."
      @file   = nil
      @verbose  = false
      @index    = 0
      @parseMode  = :default  # :webdecision
      @data   = nil   # Hash to store plugin data in

      @availableStates = {}
      @availableStates[:default]    = [:app, :appPpmXpath, :preDecisionGdl, :productXpath, :productXml, :productPpms, :productRules, ]
      @availableStates[:webdecision]  = [:app, :gdlRules, :productRules, :decisionResponse, :preDecisionGdl, ]
    end


    # Return the data hash, creating it if needed.
    def data()
      @data ||= {}
    end


    # Return data from hash.
    def [](sym)
      return data[sym]
    end


    # Return data from hash.
    def []=(sym, val)
      return data[sym] = val
    end


    # Return array of current available states.
    def availableStates()
      return @availableStates[@parseMode]
    end


    # Set the parse mode.
    def parseMode=(mode)
      @parseMode = mode if [:default, :webdecision].include?(mode)
    end


    # Set the output dir path.
    def outdir=(dir)
      @outdir = File.rubypath(dir) unless nil == dir
    end


    # Set source file and dir path
    def src_file=(file)
      fp = Pathname.new(file)
      @srcdir = fp.dirname.to_s
      @file = fp.basename.to_s
    end

    # Set the source dir path.
    def srcdir=(dir)
      @srcdir = File.rubypath(dir) unless nil == dir
    end


    # Set the name of file to parse.
    def file=(filename)
      @file = File.rubypath(filename) unless nil == filename
    end


    # Turn on verbose mode.
    def verbose=(verbose)
      @verbose = verbose
    end


    # Return the full output path including the filename.
    def outputPath(filename)
      raise "outdir missing" unless !@outdir.nil?
      outputPath = File.join(@outdir, filename)
    end


    def state=(nextState)
      raise "Invalid target state: #{nextState.to_s}" unless availableStates.include? nextState

      @state = nextState
      puts "STATE: #{nextState.to_s}" if $DEBUG
    end

    def nextIndex()
      @index += 1
    end

    def indexStr()
      return "%02d" % @index
    end


    def createValidName(inname)
      return nil if nil == inname

      outname = inname.gsub(/[\s\/\\?*#+]/,'')        # Remove illegal chars (replace with underscore).
      outname.gsub!(/_+/,"_")                 # Replace consecutive uscores with single uscore.
      outname.gsub!(/\./,"-")                 # Replace period with dash.
      outname.gsub!(/[\(\)\$]/,"")              # Remove L & R Parens, dollar signs.
      outname.gsub!(/\%/,"Perc")                # Replace '%' with Perc.

      outname
    end
  end


end # module ParseDecision
