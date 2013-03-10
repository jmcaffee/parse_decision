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
     case context.state
     when :app
       return is_ppm_xpath context, ln

     when :appPpmXpath
       return store_xpath_content context, ln

     else
       return false
     end # case
    end

    def is_ppm_xpath(context,ln)
      if ln.include?(@searchStr1)
        context.state = :appPpmXpath
        return true
      end
      return false
    end

    def store_xpath_content(context, ln)
      if ln.include?(@searchStr2)
        context.state = :app
        outfile = apply_template(@fnameTemplate, "@INDEX@", context.indexStr)
        puts "Creating App XML XPath file: #{outfile}" if context.verbose
        File.open(context.outputPath(outfile), "w") do |f|
          write_to_file(f,ln)
        end
        return true
      end

      # This is probably an empty line.
      # Return true since we're in the xpath state and there is no need for
      # any other plugin to handle this line.
      return true
    end
  end # class PpmXpath


end # module Plugin

end # module ParseDecision
