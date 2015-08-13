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

      case context.state
      when :app
        return accept_as_product_data context, ln

      when :productXml
        return accept_product_ppms context, ln

      when :productPpms
        return accept_product_rules context, ln

      when :productRules
        return process_product_rules context, ln

      else
        return false

      end # case
    end

    def accept_as_product_data(context, ln)
      if ln.include?(@searchStr1)
        context.state = :productXml
        @data.clear
        set_outfile( "" )

        # Generate the name of the output file
        match = ln.match /\sName="([^"]+)/
        product = "UnkProduct"
        if(match && match.length > 1)
          product = match[1]
        end
        @product = context.createValidName(product)
        set_outfile( apply_templates(@fnameTemplate, {"@INDEX@"=>context.indexStr, "@PROD@"=>@product}) )

        @data << ln

        create_data_file context

        @data.clear
        return true
      end

      return false
    end

    def create_data_file(context)
      puts "Creating product file: #{@outfile}" if context.verbose
      File.open(context.outputPath(@outfile), "w") do |f|
        write_to_file(f,@openTag)

        # Write the product PPM's Xpath (which was stored in the context)
        write_to_file(f,context[:productXpath] ) if ! context[:productXpath].nil?

        write_to_file(f,@data)
      end
    end

    def accept_product_ppms(context, ln)
      if ln.include?(@searchStr2)
        context.state = :productPpms

        # XML Tidy doesn't like underscores at the beginning attribute names, take care of it here.
        ln.gsub!(/_DATA_SET/, "DATA_SET")
        ln.gsub!(/_Name/, "Name")
        ln.gsub!(/_Value/, "Value")

        @data << ln
        return true
      end
    end

    def accept_product_rules(context, ln)
      if( ln.include?(@ruleStartStr) || ln.include?(@gdlStartStr) )
        context.state = :productRules

        @data << ln
        return true
      end
    end

    def process_product_rules(context, ln)
      if !ln.include?(@stopStr)
        @data << ln
        @lineCount += 1

        write_data_chunk context

        return true
      else

        @data << ln
        @lineCount += 1

        close_out_data_file context
        context.state = :app

        return true
      end
    end

    def write_data_chunk(context)
      if(@lineCount > @chunkSize)
        puts "Writing rule data chunk." if context.verbose
        File.open(context.outputPath(@outfile), "a") do |f|
          write_to_file(f,@data)
        end
        @lineCount = 0
        @data.clear
      end
    end

    def close_out_data_file(context)
      puts "Closing product file #{@outfile}." if context.verbose
      File.open(context.outputPath(@outfile), "a") do |f|
        write_to_file(f,@data)
        write_to_file(f,@closeTag)      # apply_template(@closeTag, "@TAG@", context.createValidName(@product))
      end
      @lineCount = 0
      @data.clear
    end

  end # class Product


end # module Plugin

end # module ParseDecision
