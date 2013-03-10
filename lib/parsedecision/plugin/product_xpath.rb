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
        # We just store the product xpath in the context so it can
        # be incorporated into the product rules file later.
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


end # module Plugin

end # module ParseDecision
