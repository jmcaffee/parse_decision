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


end # module Plugin

end # module ParseDecision
