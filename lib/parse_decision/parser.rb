##############################################################################
# File:: parser.rb
# Purpose:: Main Model object for ParseDecision utility
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
  # The Parser class runs the show. This class is called by the controller object
  class Parser


    def initialize()
      $LOG.debug "Parser::initialize"
      @cfg = Config.new.load
      @plugins = [Plugin::Application.new,
            Plugin::PpmXpath.new,
            Plugin::PreDecisionGuideline.new,
            Plugin::ProductXpath.new,
            Plugin::Product.new,
            ]
      @context = PDContext.new
    end


    # Return the application's version string.
    def version()
      return ParseDecision::VERSION
    end


    # Validate the configuration.
    def validateCfg(cfg)

      if(!(cfg.key?(:file) && (nil != cfg[:file])))
        puts "Missing --file option."
        return false
      end
      if(!(cfg.key?(:outdir) && (nil != cfg[:outdir])) )
        puts "Missing --outdir option."
        return false
      end

      @context.file     = cfg[:file]
      @context.outdir   = cfg[:outdir]

      if(cfg.key?(:srcdir) && cfg[:srcdir] != nil)
        @context.srcdir = cfg[:srcdir]
      end

      if(cfg.key?(:verbose) && cfg[:verbose] != nil)
        @context.verbose = cfg[:verbose]
      end

      return true

    end


    def parse(srcpath, destpath)
      path = Pathname.new srcpath
      destpath = Pathname.pwd if destpath.nil?
      parseCfg({ file: path.basename.to_s,
                 srcdir: path.dirname.to_s, outdir: destpath.to_s })
    end

    # Parse files based on the configuration.
    def parseCfg(cfg)
      $LOG.debug "Parser::parseCfg( cfg )"

      if( !validateCfg(cfg) )
        puts "ERROR: Invalid options."
        return
      end

      if( !File.exists?(@context.file) )
        @context.file = File.join( @context.srcdir, @context.file )
        if( !File.exists?(@context.file) )
          puts "ERROR: unable to locate src file: #{@context.file}"
          return
        end
      end

      if( !File.exists?(@context.outdir) )
        FileUtils.mkdir_p( @context.outdir )
        puts "Output dir created: #{@context.outdir}" if @context.verbose
      end

      parseFile(@context.file)

      # Copy the decision log to the output dir.
      FileUtils.cp(@context.file, @context.outdir)
    end


    # Parse an XML decision file.
    def parseFile(fname)
      $LOG.debug "Parser::parseFile( #{fname} )"
      puts "Parsing file: #{fname}" if @context.verbose

      # Determine the mode and configure plugins based on the file data.
      configureForFileMode(fname)

      line_count = 1
      # Open the file and read line by line
      df = File.open(fname).each do |ln|
        puts line_count.to_s if $DEBUG
        line_count += 1
        @plugins.each do |plug|
          puts "     --> #{plug.class}" if $DEBUG
          break if ( true == plug.execute(@context, ln))
        end # plugins.each
      end # do file

      puts "Lines parsed: #{line_count}" if @context.verbose
    end


    def configureForFileMode(fname)
      $LOG.debug "Parser::configureForFileMode( #{fname} )"

      mode = :default
      fileTypeFound = false

      # Open the file and read line by line looking for indications of which mode to use.
      df = File.open(fname).each do |ln|
        # Search for 'normal' decision file.
        if(ln.include?("<PARAMS>"))
          fileTypeFound = true
          puts "Decision file type = :default (not webdecision)" if @context.verbose
          break
        end

        # Search for web decision file.
        if(ln.include?("Next Decision"))
          fileTypeFound = true
          mode = :webdecision
          puts "Decision file type = :webdecision" if @context.verbose
          break
        end

        # Exit file search if mode has been determined.
        if(true == fileTypeFound)
          break
        end
      end # do file

      # If the file is a web decision, reset the plugins.
      if(mode == :webdecision)
        @context.parseMode = mode
        @plugins = [Plugin::Application.new,
              Plugin::WebProduct.new,
              ]

      end
    end


    def parseFileWithSwitch(arg)
      $LOG.debug "Parser::parseFileWithSwitch( #{arg} )"
    end


    def parseFileWithCmdLineArg(arg)
      $LOG.debug "Parser::parseFileWithCmdLineArg( #{arg} )"
    end

    # Set directory where generated files are placed.
    def setOutdir(dir)
      @context.outdir = dir
    end

    def noCmdLineArg()
      $LOG.debug "Parser::noCmdLineArg"
    end


  end # class Parser


end # module ParseDecision
