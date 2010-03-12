##############################################################################
# File:: parsedecisiontool.rb
# Purpose:: Main Model object for ParseDecision utility
# 
# Author::    Jeff McAffee 03/12/2010
# Copyright:: Copyright (c) 2010, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'ktcommon/ktpath'
require 'ktcommon/ktcmdline'

class ParseDecisionTool

  attr_accessor :someFlag
    
  def initialize()
    $LOG.debug "ParseDecisionTool::initialize"
    @cfg = ParseDecisionCfg.new.load
    @someFlag = false
  end
  

  def parseFile(fname)
    $LOG.debug "ParseDecisionTool::parseFile( #{fname} )"

	# Open the file and read line by line
	
	# 	for each line do
	#		parseLine(ln)
	#	end

  end
      
  
  def parseFileWithSwitch(arg)
    $LOG.debug "ParseDecisionTool::parseFileWithSwitch( #{arg} )"
  end
      
  
  def parseFileWithCmdLineArg(arg)
    $LOG.debug "ParseDecisionTool::parseFileWithCmdLineArg( #{arg} )"
  end
      
  
  def noCmdLineArg()
    $LOG.debug "ParseDecisionTool::noCmdLineArg"
  end
      
  
end # class ParseDecisionTool


