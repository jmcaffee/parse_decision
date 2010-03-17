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

include KtPath

      #$LOG.level = Logger::ERROR

class ParseDecisionTool



	class PDPlugin
		def initialize()
				$LOG.debug "PDPlugin::initialize"
		end

		def applyTemplate(template, pattern, replacement)
			output = template.gsub(pattern, replacement)
		end

		def execute(context, ln)
				$LOG.debug "PDPlugin::execute"
			return false
		end
	end


	class PDPluginApplication < PDPlugin
		def initialize()
				$LOG.debug "PDPluginApplication::initialize"
			@fnameTemplate = "APP.xml"
			@searchStr = "<DECISION_REQUEST><APPLICATION"
		end

		def execute(context, ln)
				#$LOG.debug "PDPluginApplication::execute"
			if(ln.include?(@searchStr))
				puts "Creating Application XML file: #{@fnameTemplate}" if context.verbose
				File.open(context.outputPath(@fnameTemplate), "w") do |f|
					f.write ln
				end
				return true
			end
			return false
		end
	end


	class PDPluginProduct < PDPlugin
		def initialize()
				$LOG.debug "PDPluginProduct::initialize"
			@fnameTemplate = "@PROD@-PRODUCT.xml"
			@searchStr = "<PRODUCTS><PRODUCT"
		end

		def execute(context, ln)
				#$LOG.debug "PDPluginProduct::execute"
			if(ln.include?(@searchStr))
				match = ln.match /\sName="([^"]+)/
				product = nil
				if(match.length > 1)
					product = match[1]
					context.product = product
					outfile = applyTemplate(@fnameTemplate, "@PROD@", product)
					puts "Creating product XML file: #{outfile}" if context.verbose
					File.open(context.outputPath(outfile), "w") do |f|
						f.write ln
					end
					return true
				end
			end
			return false
		end
	end


	class PDPluginPpmProductValues < PDPlugin
		def initialize()
				$LOG.debug "PDPluginPpmProductValues::initialize"
			@fnameTemplate = "@PROD@-PPM-Values.xml"
			@searchStr = "<PARAMS><_DATA_SET"
		end

		def execute(context, ln)
				#$LOG.debug "PDPluginPpmProductValues::execute"
			if(ln.include?(@searchStr))
				if(nil != context.product)
					outfile = applyTemplate(@fnameTemplate, "@PROD@", context.product)
					puts "Creating product PPM file: #{outfile}" if context.verbose
					File.open(context.outputPath(outfile), "w") do |f|
						f.write ln
					end
					return true
				end # context.product not nil
			end
			return false
		end
	end


	class PDPluginPpmProductRules < PDPlugin
		def initialize()
				$LOG.debug "PDPluginPpmProductRules::initialize"
			@fnameTemplate = "@PROD@-RULES.xml"
			@startStr = "<Rules>"
			@stopStr = "</Decision>"
			@ruleData = []
			@lineCount = 0
		end

		def execute(context, ln)
				#$LOG.debug "PDPluginPpmProductRules::execute"
			if(nil != context.product)
				if(!context.collectingRules)
					if(ln.include?(@startStr))
						context.collectingRules = true
						outfile = applyTemplate(@fnameTemplate, "@PROD@", context.product)
						puts ">>> Creating product rules file: #{outfile}" if context.verbose
						File.open(context.outputPath(outfile), "w") do |f|
							f.write "<#{context.product}_RULES>\n"
							f.write ln
						end
						@lineCount = 0
						@ruleData.clear
						return true
					end # ln.include start string
					return false
				else # we are collecting rules
					@ruleData << ln
					@lineCount += 1
					if(ln.include?(@stopStr))
						outfile = applyTemplate(@fnameTemplate, "@PROD@", context.product)
						File.open(context.outputPath(outfile), "a") do |f|
							f.write @ruleData
							f.write "</#{context.product}_RULES>\n"
							context.collectingRules = false
							context.product = nil
							puts "<<< Closing product rules file: #{outfile}" if context.verbose
						end
						return true
					end
					if(@lineCount > 100)
						puts "Writing 100 lines of rule data." if context.verbose
						outfile = applyTemplate(@fnameTemplate, "@PROD@", context.product)
						File.open(context.outputPath(outfile), "a") do |f|
							f.write @ruleData
						end
						@lineCount = 0
						@ruleData.clear
					end
						
					return true
				end # !collectingRules
			end # context.product not nil
			return false
		end
	end


	class PDContext

		attr_reader :outdir
		attr_reader :srcdir
		attr_reader :file
		attr_reader :verbose
			
		attr_accessor :product
		attr_accessor :collectingRules

		def initialize()
				$LOG.debug "PDContext::initialize"
			@outdir 	= nil
			@srcdir 	= "."
			@file		= nil
			@verbose	= false
			
			@product 	= nil
			@collectingRules = false
		end

		def outdir=(dir)
			@outdir = formatPath(dir, :unix) unless nil == dir
		end

		def srcdir=(dir)
			@srcdir = formatPath(dir, :unix) unless nil == dir
		end

		def file=(filename)
			@file = formatPath(filename, :unix) unless nil == filename
		end

		def verbose=(verbose)
			@verbose = verbose
		end

		def outputPath(filename)
			outputPath = File.join(@outdir, filename)
		end


	end


  attr_accessor :someFlag
    
  def initialize()
    $LOG.debug "ParseDecisionTool::initialize"
    @cfg = ParseDecisionCfg.new.load
    @someFlag = false
	@plugins = [PDPluginApplication.new, PDPluginProduct.new, PDPluginPpmProductValues.new, PDPluginPpmProductRules.new, ]
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


