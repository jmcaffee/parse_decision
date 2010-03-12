##############################################################################
# File:: parsedecisioncontroller.rb
# Purpose:: Main Controller object for ParseDecision utility
# 
# Author::    Jeff McAffee 03/12/2010
# Copyright:: Copyright (c) 2010, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'ktcommon/ktpath'
require 'ktcommon/ktcmdline'

class ParseDecisionController

  attr_accessor :someFlag
    
  def initialize()
    $LOG.debug "ParseDecisionController::initialize"
    @cfg = ParseDecisionCfg.new.load
    @someFlag = false
  end
  

  def doSomething()
    $LOG.debug "ParseDecisionController::doSomething"
  end
      
  
  def doSomethingWithSwitch(arg)
    $LOG.debug "ParseDecisionController::doSomethingWithSwitch( #{arg} )"
  end
      
  
  def doSomethingWithCmdLineArg(arg)
    $LOG.debug "ParseDecisionController::doSomethingWithCmdLineArg( #{arg} )"
  end
      
  
  def noCmdLineArg()
    $LOG.debug "ParseDecisionController::noCmdLineArg"
  end
      
  
end # class ParseDecisionController


