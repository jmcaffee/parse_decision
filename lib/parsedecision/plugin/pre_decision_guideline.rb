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

      case context.state
      when :app
        return check_for_ppms_or_rule_start context, ln

      when :preDecisionGdl
        return process_rule_data context, ln

      else
        return false
      end # case
    end

    def check_for_ppms_or_rule_start(context, ln)
      if ln.include?(@searchStrPpms)
        @ppmData = ln
        # XML Tidy doesn't like underscores at the beginning attribute names, take care of it here.
        @ppmData.gsub!(/_DATA_SET/, "DATA_SET")
        @ppmData.gsub!(/_Name/, "Name")
        @ppmData.gsub!(/_Value/, "Value")
        return true
      end

      if ln.include?(@searchStrGdl)
        context.state = :preDecisionGdl
        @ruleData.clear
        @ruleData << "<!-- #{ln} -->"   # The leading element tag is not valid XML (no quotes around attrib params).
        return true
      end

      return false
    end

    def process_rule_data(context, ln)
      # Create the rules data file if the Guideline end tag is found
      if ln.include?(@searchStrGdlEnd)
        setup_rules_file context, ln
        return true
      end

      # Close the rules data file if the rules end tag is found
      if ln.include?(@searchRulesEnd)
        close_out_rules_file context, ln
        context.state = :app
        return true
      end

      # Haven't found the start or end of the rules here,
      # we must be somewhere in the middle.
      # Store the data so it can be written to file later.
      write_rules_data context, ln

      return true
    end

    def setup_rules_file(context, ln)
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
    end

    def close_out_rules_file(context, ln)
      @ruleData << ln

      File.open(context.outputPath(@outfile), "a") do |f|
        write_to_file(f,@ruleData)
        write_to_file(f, @actualCloseTag)
      end
    end

    def write_rules_data(context, ln)
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
    end
    
  end # class PreDecisionGuideline


end # module Plugin

end # module ParseDecision
