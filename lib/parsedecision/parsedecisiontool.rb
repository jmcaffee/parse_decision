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
			
		#attr_reader :product
		attr_reader :productXpath
		#attr_accessor :collectingRules

		def initialize()
				$LOG.debug "PDContext::initialize"
			@outdir 	= nil
			@srcdir 	= "."
			@file		= nil
			@verbose	= false
			@index		= 0
			
			#@product 	= nil
			#@collectingRules = false
			@availableStates = [:app, :appPpmXpath, :preDecisionGdl, :productXpath, :productXml, :productPpms, :productRules, ]
		end

		def outdir=(dir)
			@outdir = File.rubypath(dir) unless nil == dir
		end

		def srcdir=(dir)
			@srcdir = File.rubypath(dir) unless nil == dir
		end

		def file=(filename)
			@file = File.rubypath(filename) unless nil == filename
		end

		def verbose=(verbose)
			@verbose = verbose
		end

		def outputPath(filename)
			outputPath = File.join(@outdir, filename)
		end

		def productXpath=(xpath)
			@productXpath = xpath
		end

		def state=(nextState)
			if(@availableStates.include?(nextState))
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
	# The Tool class runs the show. This class is called by the app object
	class ParseDecisionTool

		
	  def initialize()
		$LOG.debug "ParseDecisionTool::initialize"
		@cfg = Config.new.load
		@plugins = [Plugin::Application.new, 
					Plugin::PpmXpath.new, 
					Plugin::PreDecisionGuideline.new, 
					Plugin::ProductXpath.new, 
					Plugin::Product.new, 
					]
		@context = PDContext.new
	  end
	  

	  def version()
		return PARSEDECISION_VERSION
	  end
	  
	  
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
	  
	  
	  def parseCfg(cfg)
		$LOG.debug "ParseDecisionTool::parseCfg( cfg )"

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
		  
	  
	  def parseFile(fname)
		$LOG.debug "ParseDecisionTool::parseFile( #{fname} )"
		puts "Parsing file: #{fname}" if @context.verbose
		
		# Open the file and read line by line
		df = File.open(fname).each do |ln|
			@plugins.each do |plug|
				break if ( true == plug.execute(@context, ln))
			end # plugins.each
		end # do file
	  end
		  
	  
	  def parseFileWithSwitch(arg)
		$LOG.debug "ParseDecisionTool::parseFileWithSwitch( #{arg} )"
	  end
		  
	  
	  def parseFileWithCmdLineArg(arg)
		$LOG.debug "ParseDecisionTool::parseFileWithCmdLineArg( #{arg} )"
	  end
		  
		def setOutdir(dir)
			@context.outdir = dir
		end
	  
	  def noCmdLineArg()
		$LOG.debug "ParseDecisionTool::noCmdLineArg"
	  end
		  
	  
	end # class ParseDecisionTool


end # module ParseDecision