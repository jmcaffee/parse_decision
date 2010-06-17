##############################################################################
# File:: plugin.rb
# Purpose:: Plugin objects for ParseDecision utility
# 
# Author::    Jeff McAffee 04/17/2010
# Copyright:: Copyright (c) 2010, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

##############################################################################
module ParseDecision

##############################################################################
module Plugin

	## #######################################################################
	# Base class for all plugins
	class Plugin
		def initialize()
				$LOG.debug "Plugin::initialize"
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
				$LOG.debug "Plugin::execute"
			return false
		end
	end # class Plugin


	## #######################################################################
	# Application XML plugin
	class Application < Plugin
		def initialize()
				$LOG.debug "Application::initialize"
			@fnameTemplate = "@INDEX@-APP.xml"
			@searchStr = "<DECISION_REQUEST><APPLICATION"
		end

		def execute(context, ln)
				#$LOG.debug "Application::execute"
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
	end # class Application


	## #######################################################################
	# PPM XPath plugin
	class PpmXpath < Plugin
		def initialize()
				$LOG.debug "PpmXpath::initialize"
			@fnameTemplate = "@INDEX@-APP-PPMXPATH.xml"
			@searchStr1 = "*APP XPATH xml*"
			@searchStr2 = "<PPXPATH>"
		end

		def execute(context, ln)
				#$LOG.debug "PpmXpath::execute"
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
	end # class PpmXpath


	## #######################################################################
	# Pre-Decision Guideline XML plugin
	class PreDecisionGuideline < Plugin
	
		attr_reader :ppmData
		
		def initialize()
				$LOG.debug "PreDecisionGuideline::initialize"
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
				#$LOG.debug "PreDecisionGuideline::execute"
			if((context.state == :app) && ln.include?(@searchStrPpms))
				@ppmData = ln
				# XML Tidy doesn't like underscores at the beginning attribute names, take care of it here.
				@ppmData.gsub!(/_DATA_SET/, "DATA_SET")
				@ppmData.gsub!(/_Name/, "Name")
				@ppmData.gsub!(/_Value/, "Value")
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
	end # class PreDecisionGuideline

	
	## #######################################################################
	# Product XPath plugin
	class ProductXpath < Plugin
		def initialize()
				$LOG.debug "ProductXpath::initialize"
			@searchStr1 = "*PRODUCT XPATH xml*"
			@searchStr2 = "<PPXPATH>"
		end

		def execute(context, ln)
				#$LOG.debug "ProductXpath::execute"
			if((context.state == :app) && ln.include?(@searchStr1))
				context.state = :productXpath
				return true
			end
				
			if((context.state == :productXpath) && ln.include?(@searchStr2))
				context.state = :app
				context[:productXpath] = ln
				return true
			end
			
			if(context.state == :productXpath)
				# Probably a blank line. Claim it so we don't waste anyone else's time.
				return true
			end

			return false
		end
	end # class ProductXpath

	

	## #######################################################################
	# Product info plugin
	class Product < Plugin
		attr_reader :data
		
		def initialize()
				$LOG.debug "Product::initialize"
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
				#$LOG.debug "Product::execute"
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
					f.write context[:productXpath] if !context[:productXpath].nil?
					f.write @data
				end
				@data.clear
				return true
			end
			
			if((context.state == :productXml) && ln.include?(@searchStr2))
				context.state = :productPpms
				
				# XML Tidy doesn't like underscores at the beginning attribute names, take care of it here.
				ln.gsub!(/_DATA_SET/, "DATA_SET")
				ln.gsub!(/_Name/, "Name")
				ln.gsub!(/_Value/, "Value")

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
	end # class Product

	
	## #######################################################################
	# Product info plugin - specific to webdecisions
	class WebProduct < Plugin
		attr_reader :data
		
		def initialize()
				$LOG.debug "WebProduct::initialize"
			@fnameTemplate 	= "@INDEX@-@PROD@-PRODUCT.xml"

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
			@productIndex	= 1
			@appIndex		= "00"

		end

		def productIndexStr()
			return "%02d" % @productIndex
		end
		
		
		def execute(context, ln)
				#$LOG.debug "WebProduct::execute"
			if((context.state == :app) && ln.include?(@ruleStartStr))
				context.state = :gdlRules
				@data.clear
				@outfile = ""
				
				if(!@appIndex.eql?(context.indexStr))
					@productIndex = 1
					@appIndex = context.indexStr
				end
				
				product = productIndexStr()
				@productIndex += 1
				@product = context.createValidName(product)
				@outfile = applyTemplates(@fnameTemplate, {"@INDEX@"=>context.indexStr, "@PROD@"=>@product})
				puts "Creating product file: #{@outfile}" if context.verbose
				@data << ln
				File.open(context.outputPath(@outfile), "w") do |f|
					f.write applyTemplate(@openTag, "@TAG@", context.createValidName(@product))
					f.write context[:productXpath] if !context[:productXpath].nil?
					f.write @data
				end
				@data.clear
				return true
			end
			
			if((context.state == :gdlRules))
				context.state = :productRules
				
				@data << ln
				return true
			end
			
			if((context.state == :productRules) && !ln.include?(@stopStr))
				if(ln.include?("----"))				# Skip comment lines (they are not valid XML).
					commentLine = ln.slice(0,4)
					return true if(commentLine.include?("----"))
				end
				
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
				#@productIndex = 1
				return true
			end
			
			return false
		end
	end # class WebProduct
	
end # module Plugin

end # module ParseDecision
