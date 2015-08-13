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


end # module Plugin

end # module ParseDecision
