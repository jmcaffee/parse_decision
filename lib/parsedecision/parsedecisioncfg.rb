##############################################################################
# File:: parsedecisioncfg.rb
# Purpose:: ParseDecision configuration file reader/writer class.
# 
# Author::    Jeff McAffee 03/12/2010
# Copyright:: Copyright (c) 2010, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'ktcommon/ktcfg'

class ParseDecisionCfg < KtCfg::CfgFile

  attr_accessor :cfg
  

  def initialize(rootDir=nil)
    $LOG.debug "ParseDecisionCfg::initialize"
    super
    @cfg = {}
    
    setDefaults()
  end
  
  
  def setDefaults
    $LOG.debug "ParseDecisionCfg::setDefaults"
    @cfg[:appPath] = formatPath(File.join(ENV["LOCALAPPDATA"], "parsedecision"), :unix)
  end
  
  
  # Load the YAML configuration file.
  # returns:: a hash containing configuration info.
  def load
    $LOG.debug "ParseDecisionCfg::load"
	
	filepath = cfgFilePath("parsedecisioncfg.yml")
    if(!File.exists?( filepath ))		# TODO: This needs to be moved into KtCfg.
		$LOG.debug "Config file does not exist. Returning default config obj."
		return @cfg
	end

	@cfg = read("parsedecisioncfg.yml")
  end
  
  
  # Save the @cfg hash to a YAML file.
  def save
    $LOG.debug "ParseDecisionCfg::save"
    write("parsedecisioncfg.yml", @cfg)
  end
  
  
end # class ParseDecisionCfg
