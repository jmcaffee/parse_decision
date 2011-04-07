##############################################################################
# File:: controller.rb
# Purpose:: Main Controller object for ParseDecision utility
# 
# Author::    Jeff McAffee 03/12/2010
# Copyright:: Copyright (c) 2010, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'ktcommon/ktpath'
require 'ktcommon/ktcmdline'

##############################################################################
# Everything is contained in Module	ParseDecision
module ParseDecision
	  
	##########################################################################
	# Controller class handles interactions bewteen the view (cmdline script)
	# and the model (Tool).
	class Controller

	  def initialize()
		$LOG.debug "Controller::initialize"
		@cfg = Config.new.load
		@cfg = Config.new.load
		@model = Parser.new
	  end
	  
		
	  # Save the current config values and start the parse.
	  def execute()
		$LOG.debug "Controller::execute"
		
		# Save current cfg
		Config.new.save( @cfg )
		@model.parseCfg( @cfg )
	  end
		  
	  # Set switches with values from a hash. This should only be
	  # called from +setOptions+.
	  def setSwitches(options={})
		$LOG.debug "Controller::setSwitches( options={} )"
		
		if(options.length)
			options.each do |opt, arg|
				case opt 
					when :logging
						cfgCtrl = Config.new
						cfgCtrl.load
						cfgCtrl.addKeyValue(:logging, arg)
						cfgCtrl.save
					
					when :reset
						cfgCtrl = Config.new
						cfgCtrl.save
					
					when :verbose
						# Set verbose flag
						@cfg[:verbose] = true
					
					when :version
						# Print the version and exit.
						verStr1 = "#{ParseDecision::APPNAME} v#{@model.version}"
						verStr2 = "#{ParseDecision::COPYRIGHT}"
						puts verStr1
						puts verStr2
						puts
						exit
						
					else
						# Don't know what you want but I don't recognize it.
					
				end # case opt
			end # options.each
		end # if more than 1 option
	  end
	  private :setSwitches  
	  
	  # Set all options and switches with values from a hash.
	  def setOptions(options={})
		$LOG.debug "Controller::setOptions( options={} )"
		
		setSwitches(options)
		
		if(options.length)
			options.each do |opt, arg|
				case opt 
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
			end # options.each
		
			cfgCtrl = Config.new
			cfgCtrl.load
			cfgCtrl.cfg.merge!(@cfg)
			cfgCtrl.save
		end # if more than 1 option
	  end
		  
	  
	  # Command line arg will be used as the +outdir+.
	  def executeWithCmdLineArg(arg)
		$LOG.debug "Controller::executeWithCmdLineArg( #{arg} )"
		@cfg[:outdir] = arg
		return true # if ok to continue, false to exit app.
	  end
		  
	  
	  # Make sure +outdir+ has been set.
	  # Returns true as long as outdir is set one way or the other.
	  def noCmdLineArg()
		$LOG.debug "Controller::noCmdLineArg"
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
		  
	  
	end # class Controller


end # module ParseDecision
