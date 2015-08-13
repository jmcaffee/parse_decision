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
