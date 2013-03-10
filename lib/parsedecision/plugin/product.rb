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


end # module Plugin

end # module ParseDecision
