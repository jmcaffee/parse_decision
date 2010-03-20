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

		def applyTemplates(template, repPatterns)
			output = template
			repPatterns.each do |p,r|
				output = output.gsub(p, r)
			end # repPatterns.each
			output
		end

		def execute(context, ln)
				$LOG.debug "PDPlugin::execute"
			return false
		end
	end


	class PDPluginApplication < PDPlugin
		def initialize()
				$LOG.debug "PDPluginApplication::initialize"
			@fnameTemplate = "@INDEX@-APP.xml"
			@searchStr = "<DECISION_REQUEST><APPLICATION"
		end

		def execute(context, ln)
				#$LOG.debug "PDPluginApplication::execute"
			if(ln.include?(@searchStr))
				context.nextIndex
				context.state = :app
				outfile = applyTemplate(@fnameTemplate, "@INDEX@", context.indexStr)
				puts "Creating Application XML file: #{outfile}" if context.verbose
				File.open(context.outputPath(outfile), "w") do |f|
					f.write ln
				end
				return true
			end
			return false
		end
	end


	class PDPluginPpmXpath < PDPlugin
		def initialize()
				$LOG.debug "PDPluginPpmXpath::initialize"
			@fnameTemplate = "@INDEX@-APP-PPMXPATH.xml"
			@searchStr1 = "*APP XPATH xml*"
			@searchStr2 = "<PPXPATH>"
		end

		def execute(context, ln)
				#$LOG.debug "PDPluginPpmXpath::execute"
			if((context.state == :app) && ln.include?(@searchStr1))
				context.state = :appPpmXpath
				return true
			elsif((context.state == :appPpmXpath) && ln.include?(@searchStr2))
				context.state = :app
				outfile = applyTemplate(@fnameTemplate, "@INDEX@", context.indexStr)
				puts "Creating App XML XPath file: #{outfile}" if context.verbose
				File.open(context.outputPath(outfile), "w") do |f|
					f.write ln
				end
				return true
			elsif(context.state == :appPpmXpath)
				# Is probably an empty line.
				# Return true since we're in the xpath state and there is no need for
				# any other plugin to handle this line.
				return true
			end
			return false
		end
	end


	class PDPluginPreDecisionGuideline < PDPlugin
		def initialize()
				$LOG.debug "PDPluginPreDecisionGuideline::initialize"
			@fnameTemplate 		= "@INDEX@-@GDL@-Rules.xml"
			@searchStrPpms 		= "<PARAMS><_DATA_SET"
			@searchStrGdl 		= "<Guideline "
			@searchStrGdlEnd	= "<Decision GuidelineId"
			@ppmData 			= ""
			@ruleData			= []
			
			@openTag			= "<@TAG@_DATA>\n"
			@closeTag			= "</@TAG@_DATA>\n"
		end

		def execute(context, ln)
				#$LOG.debug "PDPluginPreDecisionGuideline::execute"
			if((context.state == :app) && ln.include?(@searchStrPpms))
				@ppmData = ln
				return true
			elsif((context.state == :app) && ln.include?(@searchStrGdl))
				context.state = :preDecisionGdl
				@ruleData.clear
				@ruleData << "<!-- #{ln} -->"		# The leading element tag is not valid XML (no quotes around attrib params).
				return true
			elsif((context.state == :preDecisionGdl) && ln.include?(@searchStrGdlEnd))
				@ruleData << ln
				gdlName = "PreDecision"
				match = ln.match /\sGuidelineName="([^"]+)/
				if(match && match.length > 1)
					gdlName = match[1]
					gdlName = context.createValidName(gdlName)
				end

				outfile = applyTemplates(@fnameTemplate, {"@INDEX@"=>context.indexStr, "@GDL@"=>gdlName})
					
				puts "Creating Gdl Rules file: #{outfile}" if context.verbose
				
				File.open(context.outputPath(outfile), "w") do |f|
					f.write applyTemplate(@openTag, "@TAG@", gdlName)
					f.write @ppmData
					f.write @ruleData
					f.write applyTemplate(@closeTag, "@TAG@", gdlName)
				end
				context.state = :app
				return true
			elsif(context.state == :preDecisionGdl)
				@ruleData << ln
				return true
			end
			return false
		end
	end

	
	class PDPluginProductXpath < PDPlugin
		def initialize()
				$LOG.debug "PDPluginProductXpath::initialize"
			@searchStr1 = "*PRODUCT XPATH xml*"
			@searchStr2 = "<PPXPATH>"
		end

		def execute(context, ln)
				#$LOG.debug "PDPluginProductXpath::execute"
			if((context.state == :app) && ln.include?(@searchStr1))
				context.state = :productXpath
				return true
			end
				
			if((context.state == :productXpath) && ln.include?(@searchStr2))
				context.state = :app
				context.productXpath = ln
				return true
			end
			
			if(context.state == :productXpath)
				# Probably a blank line. Claim it so we don't waste anyone else's time.
				return true
			end

			return false
		end
	end

	

	class PDPluginProduct < PDPlugin
		
		def initialize()
				$LOG.debug "PDPluginProduct::initialize"
			@fnameTemplate 	= "@INDEX@-@PROD@-PRODUCT.xml"
			@searchStr1 	= "<PRODUCTS><PRODUCT"
			@searchStr2 	= "<PARAMS><_DATA_SET"

			@ruleStartStr 	= "<Rules>"
			@gdlStartStr 	= "<Decision GuidelineId"
			@stopStr 		= "</Decision>"

			@data 			= []
			@outfile 		= ""
			@openTag		= "<@TAG@_DATA>\n"
			@closeTag		= "</@TAG@_DATA>\n"
			@lineCount 		= 0
			@chunkSize 		= 1000
			@product		= ""

		end

		def execute(context, ln)
				#$LOG.debug "PDPluginProduct::execute"
			if((context.state == :app) && ln.include?(@searchStr1))
				context.state = :productXml
				@data.clear
				@outfile = ""

				match = ln.match /\sName="([^"]+)/
				product = "UnkProduct"
				if(match && match.length > 1)
					product = match[1]
				end
				@product = context.createValidName(product)
				@outfile = applyTemplates(@fnameTemplate, {"@INDEX@"=>context.indexStr, "@PROD@"=>@product})
				puts "Creating product file: #{@outfile}" if context.verbose
				@data << ln
				File.open(context.outputPath(@outfile), "w") do |f|
					f.write applyTemplate(@openTag, "@TAG@", context.createValidName(@product))
					f.write context.productXpath
					f.write @data
				end
				@data.clear
				return true
			end
			
			if((context.state == :productXml) && ln.include?(@searchStr2))
				context.state = :productPpms
				
				@data << ln
				return true
			end
			
			if((context.state == :productPpms) && (ln.include?(@ruleStartStr) || ln.include?(@gdlStartStr)))
				context.state = :productRules
				
				@data << ln
				return true
			end
			
			if((context.state == :productRules) && !ln.include?(@stopStr))
				@data << ln
				@lineCount += 1
				
				if(@lineCount > @chunkSize)
					puts "Writing rule data chunk." if context.verbose
					File.open(context.outputPath(@outfile), "a") do |f|
						f.write @data
					end
					@lineCount = 0
					@data.clear
				end
				return true
			end
			
			if((context.state == :productRules) && ln.include?(@stopStr))
				@data << ln
				@lineCount += 1
				
				puts "Closing product file." if context.verbose
				File.open(context.outputPath(@outfile), "a") do |f|
					f.write @data
					f.write applyTemplate(@closeTag, "@TAG@", context.createValidName(@product))
				end
				@lineCount = 0
				@data.clear
				context.state = :app
				return true
			end
			
			return false
		end
	end


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


  attr_accessor :someFlag
    
  def initialize()
    $LOG.debug "ParseDecisionTool::initialize"
    @cfg = ParseDecisionCfg.new.load
    @someFlag = false
	@plugins = [PDPluginApplication.new, 
				PDPluginPpmXpath.new, 
				PDPluginPreDecisionGuideline.new, 
				PDPluginProductXpath.new, 
				PDPluginProduct.new, 
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


