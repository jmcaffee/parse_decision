##############################################################################
# File:: plugin.rb
# Purpose:: Plugin objects for ParseDecision utility
#
# Author::    Jeff McAffee 04/17/2010
# Copyright:: Copyright (c) 2010, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

#############################################################
#   Stage Change Flow
#
# default mode:
#   :app
#     :appPpmXpath
#       :preDecisionGdl
#         :productXpath
#           :productXml
#             :productPpms
#               :productRules
#
# webdecision mode:
#   :app
#     :gdlRules
#       :productRules
#         :decisionResponse
#           :preDecisionGdl
#
#
#
#
#############################################################


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

    def apply_template(template, pattern, replacement)
      output = template.gsub(pattern, replacement)
    end

    def apply_templates(template, repPatterns)
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

    def write_to_file(f,data)
      if(data.class == Array)
        data.each do |ln|
          f.write ln
        end
      else
        f.write data
      end
    end


  end # class Plugin


  ## #######################################################################
  # Application XML plugin
  class Application < Plugin
    def initialize()
      $LOG.debug "Application::initialize"
      @fnameTemplate = "@INDEX@-APP.xml"
      @searchStr = "<DECISION_REQUEST><APPLICATION"
      @searchStr = "<APPLICATION "            # Note that the space at end is required.
    end

    def execute(context, ln)
     #$LOG.debug "Application::execute"
      if(ln.include?(@searchStr))
        context.nextIndex
        context.state = :app
        outfile = apply_template(@fnameTemplate, "@INDEX@", context.indexStr)
        puts "" if context.verbose
        puts "= = = = = = = = = = = = = = = = = = = = = = = = = = = =" if context.verbose
        puts "" if context.verbose
        puts "Creating Application XML file: #{outfile}" if context.verbose
        File.open(context.outputPath(outfile), "w") do |f|
          write_to_file(f,ln)
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
     #require 'pry'; binding.pry
      if((context.state == :app) && ln.include?(@searchStr1))
        context.state = :appPpmXpath
        return true
      elsif((context.state == :appPpmXpath) && ln.include?(@searchStr2))
        context.state = :app
        outfile = apply_template(@fnameTemplate, "@INDEX@", context.indexStr)
        puts "Creating App XML XPath file: #{outfile}" if context.verbose
        File.open(context.outputPath(outfile), "w") do |f|
          write_to_file(f,ln)
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
    attr_reader :outfile

    def initialize()
      $LOG.debug "PreDecisionGuideline::initialize"
      @fnameTemplate    = "@INDEX@-@GDL@-Rules.xml"
      @searchStrPpms    = "<PARAMS><_DATA_SET"
      @searchStrGdl     = "<Guideline "
      @searchStrGdlEnd  = "<Decision GuidelineId"
      @searchRulesEnd   = "</Decision>"
      @ppmData      = ""
      @ruleData     = []

      @openTag      = "<@TAG@_DATA>\n"
      @closeTag     = "</@TAG@_DATA>\n"
      @actualCloseTag = ""
      @lineCount    = 0
      @chunkSize    = 1000
      @outfile      = "PreDecision"
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
        @ruleData << "<!-- #{ln} -->"   # The leading element tag is not valid XML (no quotes around attrib params).
        return true
      elsif((context.state == :preDecisionGdl) && ln.include?(@searchStrGdlEnd))
        @ruleData << ln

        # Default guideline name
        gdlName = "PreDecision"

        # String#match acts weird so using RegEx/MatchData here.
        m = /\sGuidelineName="([^"]+)/.match(ln)
        if m[1].length > 1
          gdlName = m[1]
          gdlName = context.createValidName(gdlName)
        end

        @outfile = apply_templates(@fnameTemplate, {"@INDEX@"=>context.indexStr, "@GDL@"=>gdlName})

        # Store the closing tag for later.
        @actualCloseTag = apply_template(@closeTag, "@TAG@", gdlName)

        puts "Creating Gdl Rules file: #{@outfile}" if context.verbose

        File.open(context.outputPath(@outfile), "w") do |f|
          write_to_file(f, apply_template(@openTag, "@TAG@", gdlName))
          write_to_file(f,@ppmData)
        end
        return true
      elsif((context.state == :preDecisionGdl) && ln.include?(@searchRulesEnd))
        @ruleData << ln

        File.open(context.outputPath(@outfile), "a") do |f|
          write_to_file(f,@ruleData)
          write_to_file(f, @actualCloseTag)
        end
        context.state = :app
        return true
      elsif(context.state == :preDecisionGdl)
        @ruleData << ln
        @lineCount += 1

        if(@lineCount > @chunkSize)
          puts "Writing rule data chunk." if context.verbose
          File.open(context.outputPath(@outfile), "a") do |f|
            write_to_file(f,@ruleData)
          end
          @lineCount = 0
          @ruleData.clear
        end
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
      puts "! Product::initialize"
      @fnameTemplate  = "@INDEX@-@PROD@-PRODUCT.xml"
      @searchStr1   = "<PRODUCTS><PRODUCT"
      @searchStr2   = "<PARAMS><_DATA_SET"

      @ruleStartStr   = "<Rules>"
      @gdlStartStr  = "<Decision GuidelineId"
      @stopStr    = "</Decision>"

      @data       = []
      @openTag    = "<@TAG@_DATA>\n"
      @closeTag   = "</@TAG@_DATA>\n"
      @openTag    = "<PRODUCT_DATA>\n"
      @closeTag   = "</PRODUCT_DATA>\n"
      @lineCount    = 0
      @chunkSize    = 1000
      @product    = ""

      set_outfile( "" )
    end

    def set_outfile( outfile )
      @outfile = outfile
    end

    def execute(context, ln)
        #$LOG.debug "Product::execute"

      if((context.state == :app) && ln.include?(@searchStr1))
        context.state = :productXml
        @data.clear
        set_outfile( "" )

        match = ln.match /\sName="([^"]+)/
        product = "UnkProduct"
        if(match && match.length > 1)
          product = match[1]
        end
        @product = context.createValidName(product)
        set_outfile( apply_templates(@fnameTemplate, {"@INDEX@"=>context.indexStr, "@PROD@"=>@product}) )
        puts "Creating product file: #{@outfile}" if context.verbose
        @data << ln
        File.open(context.outputPath(@outfile), "w") do |f|
          write_to_file(f,@openTag)         # apply_template(@openTag, "@TAG@", context.createValidName(@product))
          #debugger
          write_to_file(f,context[:productXpath] ) if ! context[:productXpath].nil?
          write_to_file(f,@data)
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
            write_to_file(f,@data)
          end
          @lineCount = 0
          @data.clear
        end
        return true
      end

      if((context.state == :productRules) && ln.include?(@stopStr))
        @data << ln
        @lineCount += 1

        puts "Closing product file #{@outfile}." if context.verbose
        File.open(context.outputPath(@outfile), "a") do |f|
          write_to_file(f,@data)
          write_to_file(f,@closeTag)      # apply_template(@closeTag, "@TAG@", context.createValidName(@product))
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
      @fnameTemplate  = "@INDEX@-@PROD@-PRODUCT.xml"

      @ruleStartStr   = "<Rules>"
      @gdlStartStr  = "<Decision GuidelineId"
      @stopStr    = "</Decision>"

      @openProgramNameDpm = '>'
      @closeProgramNameDpm = '</DPM>'


      @data       = []
      @outfile    = ""
      @openTag    = "<@TAG@_DATA>\n"
      @closeTag   = "</@TAG@_DATA>\n"
      @openTag    = "<PRODUCT_DATA>\n"
      @closeTag   = "</PRODUCT_DATA>\n"
      @lineCount    = 0
      @chunkSize    = 1000
      @product    = ""
      @productIndex = 1
      @appIndex   = "00"

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
        context["programNameFound"] = false
        context["productName"]    = ""

        if(!@appIndex.eql?(context.indexStr))
          @productIndex = 1
          @appIndex = context.indexStr
        end

        product = "Product" + productIndexStr()
        @productIndex += 1
        @product = context.createValidName(product)
        @outfile = apply_templates(@fnameTemplate, {"@INDEX@"=>context.indexStr, "@PROD@"=>@product})
        puts "" if context.verbose
        puts "- + - + - + -" if context.verbose
        puts "" if context.verbose
        puts "Creating product file: #{@outfile}" if context.verbose
        @data << ln
        File.open(context.outputPath(@outfile), "w") do |f|
          write_to_file(f,@openTag)     # apply_template(@openTag, "@TAG@", context.createValidName(@product))
          write_to_file(f,context[:productXpath]) if ! context[:productXpath].nil?
          write_to_file(f,@data)
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
        if(ln.include?("----"))       # Skip comment lines (they are not valid XML).
          commentLine = ln.slice(0,4)
          return true if(commentLine.include?("----"))
        end

        @data << ln
        @lineCount += 1

        if(!context["programNameFound"])
          if(ln.include?('Name="Program Name"'))
            productName = getSubString(ln, @openProgramNameDpm, @closeProgramNameDpm)
            context["programNameFound"] = true
            context["productName"] = productName
            puts "........Program Name DPM found: #{productName}" if context.verbose

          end # if ln.include?
        end # if !context["programNameFound"]

        if(@lineCount > @chunkSize)
          puts "Writing rule data chunk." if context.verbose
          File.open(context.outputPath(@outfile), "a") do |f|
            write_to_file(f,@data)
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
          write_to_file(f,@data)
          write_to_file(f,@closeTag)    # apply_template(@closeTag, "@TAG@", context.createValidName(@product))
        end
        @lineCount = 0
        @data.clear
        context.state = :app
        #@productIndex = 1

        if(context["programNameFound"])
          pname = context.createValidName(context["productName"])
          newFileName = apply_templates(@fnameTemplate, {"@INDEX@"=>context.indexStr, "@PROD@"=>pname})

          renameFile(context, @outfile, newFileName)
        end # if context["programNameFound"]

        context["programNameFound"] = false

        return true
      end

      return false
    end


    def getSubString(haystack, startDelim, stopDelim)
        #$LOG.debug "WebProduct::getSubString( #{haystack}, #{startDelim}, #{stopDelim} )"
        #puts "WebProduct::getSubString()" # #{haystack}, #{startDelim}, #{stopDelim} )"
        #puts "    haystack: #{haystack}"
        #puts "  startDelim: #{startDelim}"
        #puts "   stopDelim: #{stopDelim}"

      start   = haystack.index(startDelim)
        #puts "       start: " + (start.nil? ? "nil" : "#{start}")
      return if start.nil?

      start += startDelim.size
      stop  = haystack.rindex(stopDelim)

      res   = haystack[start,(stop - start)]
    end # getSubString


    def renameFile(context, srcFileName, destFileName)
      puts "Renaming #{srcFileName} => #{destFileName}" if context.verbose
      FileUtils.mv(context.outputPath(srcFileName), context.outputPath(destFileName))
    end # renameFile


  end # class WebProduct

end # module Plugin

end # module ParseDecision
