##############################################################################
# File:: parsedecisiontask.rb
# Purpose:: Rake Task for running the application
# 
# Author::    Jeff McAffee 04/16/2010
# Copyright:: Copyright (c) 2010, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'parsedecision'
class ParseDecisionTask

	def execute(logSrcPath, destDir, verbose=false)
		
		dsnFile = File.basename(logSrcPath)
		dsnDir	= File.dirname(logSrcPath)
		
		app = ParseDecision::ParseDecisionController.new
		
		# Set switches
		
		app.setUserSwitch :reset, true			# Reset the config file every time.
		app.setUserSwitch :verbose, verbose
		
		# Set options
		
		app.setUserOption :file, dsnFile		# Name of decision file.
		app.setUserOption :srcdir, dsnDir		# Path to src decision file directory.
		app.setUserOption :outdir, destDir		# Path to dir where results will be placed.
		app.doSomething()
	end
end # class ParseDecisionTask


