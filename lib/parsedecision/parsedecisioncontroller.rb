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
    @cfg = ParseDecisionCfg.new.load
    @someFlag = false
	@model = ParseDecisionTool.new
  end
  

  def doSomething()
    $LOG.debug "ParseDecisionController::doSomething"
	
	# Save current cfg
	ParseDecisionCfg.new.save( @cfg )
	@model.parseCfg( @cfg )
  end
      
  
  def setUserSwitch(switch, arg)
    $LOG.debug "ParseDecisionController::setUserSwitch( #{switch.to_s}, #{arg} )"
	
	case switch 
		when :logging
			cfgCtrl = ParseDecisionCfg.new
			cfgCtrl.load
			cfgCtrl.addKeyValue(:logging, arg)
			cfgCtrl.save
		
		when :reset
			cfgCtrl = ParseDecisionCfg.new
			cfgCtrl.save
		
		when :verbose
			# Set verbose flag
			@cfg[:verbose] = true
		
		when :version
			# Print the version and exit.
			verStr1 = "#{PARSEDECISION_APPNAME} v#{@model.version}"
			verStr2 = "#{PARSEDECISION_COPYRIGHT}"
			puts verStr1
			puts verStr2
			puts
			
		else
			# Don't know what you want but I don't recognize it.
		
	end
  end
      
  
  def setUserOption(option, arg)
    $LOG.debug "ParseDecisionController::setUserOption( #{option.to_s}, #{arg} )"
	
	case option 
		when :file
			# Set cfg decision file name
			@cfg[:file] = arg
		
		when :outdir
			# Set context output dir
			@cfg[:outdir] = arg
		
		when :srcdir
			# Set context src dir
			@cfg[:srcdir] = arg
			
		else
			# Don't know what you want but I don't recognize it.
		
	end
	
	@cfg.save
  end
      
  
  def doSomethingWithCmdLineArg(arg)
    $LOG.debug "ParseDecisionController::doSomethingWithCmdLineArg( #{arg} )"
	@cfg[:outdir] = arg
	return true # if ok to continue, false to exit app.
  end
      
  
  def noCmdLineArg()
    $LOG.debug "ParseDecisionController::noCmdLineArg"
	if( @cfg.key?(:outdir) && !@cfg[:outdir].empty? )
		return true # if ok to continue, false to exit app.
	end
	
	puts "Missing output directory argument."
	puts
	puts "The outdir needs to be set at least one time."
	puts "Use the -o option or supply the output directory path on the command line."
	puts "Use -h for help."
	return false # to exit app.
  end
      
  
end # class ParseDecisionController


