##############################################################################
# File:: parsedecisiontool.rb
# Purpose:: Main Model object for ParseDecision utility
# 
# Author::    Jeff McAffee 03/12/2010
# Copyright:: Copyright (c) 2010, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'ktcommon/ktpath'
require 'ktcommon/ktcmdline'
require 'parsedecision/plugin'

      #$LOG.level = Logger::ERROR

##############################################################################
# Everything is contained in Module	ParseDecision
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
			@outdir 	= nil
			@srcdir 	= "."
			@file		= nil
			@verbose	= false
			@index		= 0
			@parseMode	= :default 	# :webdecision
			@data		= nil		# Hash to store plugin data in
			
			@availableStates = {}
			@availableStates[:default] 		= [:app, :appPpmXpath, :preDecisionGdl, :productXpath, :productXml, :productPpms, :productRules, ]
			@availableStates[:webdecision] 	= [:app, :gdlRules, :productRules, :decisionResponse, :preDecisionGdl, ]
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
			outputPath = File.join(@outdir, filename)
		end

		
		def state=(nextState)
			if((availableStates).include?(nextState))
				@state = nextState
			else
				puts "ERROR: Unknown state change requested to unknown state: #{nextState.to_s}"
			end
		end

		def nextIndex()
			@index += 1
		end

		def indexStr()
			return "%02d" % @index
		end
		
		
		def createValidName(inname)
			return nil if nil == inname
			
			outname = inname.gsub(/[\s\/\\?*#+]/,'')				# Remove illegal chars (replace with underscore).
			outname.gsub!(/_+/,"_")									# Replace consecutive uscores with single uscore.
			outname.gsub!(/\./,"-")									# Replace period with dash.
			outname.gsub!(/[\(\)\$]/,"")							# Remove L & R Parens, dollar signs.
			outname.gsub!(/\%/,"Perc")								# Replace '%' with Perc.

			outname
		end



	end


	  
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
		return PARSEDECISION_VERSION
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
		
		@context.file 		= cfg[:file]
		@context.outdir 	= cfg[:outdir]
		
		if(cfg.key?(:srcdir) && cfg[:srcdir] != nil)
			@context.srcdir = cfg[:srcdir]
		end
		
		if(cfg.key?(:verbose) && cfg[:verbose] != nil)
			@context.verbose = cfg[:verbose]
		end
		
		return true
	  
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
			puts "Output dir created: #{@context.outdir}"
		end
			
		parseFile(@context.file)
		
		FileUtils.cp(@context.file, @context.outdir)	# Copy the decision log to the output dir.
	  end
		  
	  
	  # Parse an XML decision file.
	  def parseFile(fname)
		$LOG.debug "Parser::parseFile( #{fname} )"
		puts "Parsing file: #{fname}" if @context.verbose
		
		# Determine the mode and configure plugins based on the file data.
		configureForFileMode(fname)
		
		# Open the file and read line by line
		df = File.open(fname).each do |ln|
			@plugins.each do |plug|
				break if ( true == plug.execute(@context, ln))
			end # plugins.each
		end # do file
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
				puts "Decision file type = :default (not webdecision)"
				break
			end
			
			# Search for web decision file.
			if(ln.include?("Next Decision"))
				fileTypeFound = true
				mode = :webdecision
				puts "Decision file type = :webdecision"
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