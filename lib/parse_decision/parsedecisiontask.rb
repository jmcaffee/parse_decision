##############################################################################
# File:: parsedecisiontask.rb
# Purpose:: Rake Task for running the application
# 
# Author::    Jeff McAffee 04/16/2010
# Copyright:: Copyright (c) 2010, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'parse_decision'
class ParseDecisionTask

	def execute(logSrcPath, destDir, verbose=false)
		
		dsnFile = File.basename(logSrcPath)
		dsnDir	= File.dirname(logSrcPath)
		
		app = ParseDecision::Controller.new
		
		options = {	:reset => true, 			# Set switches
					:verbose => verbose,
					:file => dsnFile,			# Set options
					:srcdir => dsnDir,
					:outdir => destDir, }
					
		app.setOptions( options )
		app.execute()
	end
end # class ParseDecisionTask


