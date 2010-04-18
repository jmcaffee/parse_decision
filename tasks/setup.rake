##############################################################################
# File:: setup.rake
# Purpose:: Tasks that call various methods on the setup.rb app.
# 
# Author::    Jeff McAffee 04/18/2010
#
##############################################################################

require 'rake'
require 'rake/clean'


namespace :setup do

  #######################################

	task :init do
		noErrs = true
=begin		
		if(!defined?(CLIENT) == nil || CLIENT.empty?)
			puts "* ERROR: dbg: CLIENT constant must be defined."
			noErrs = false
		end
		
		if(!defined?(PPMXML) == nil || PPMXML.empty?)
			puts "* ERROR: dbg: PPMXML constant must be defined."
			noErrs = false
		end
		
		if(!defined?(PROJDIR) == nil || PROJDIR.empty?)
			puts "* ERROR: dbg: PROJDIR constant must be defined."
			noErrs = false
		end
		
		if(!defined?(SRCDIR) == nil || SRCDIR.empty?)
			puts "* ERROR: dbg: SRCDIR constant must be defined."
			noErrs = false
		end
=end

		exit unless noErrs
		
	end


  #######################################

	desc "install"
	task :install => :init do
		puts "* setup:install: running setup" if $verbose
		ruby('setup.rb')
		
	end
	

  #######################################

	desc "un-install"
	task :uninst => :init do
		puts "* setup:uninst: removing files from Ruby dirs" if $verbose
		ruby('setup.rb', 'clean')
		
	end
	

  #######################################

	desc "run all tests"
	task :test => :init do
		puts "* setup:test: running all tests in test dir" if $verbose
		ruby('setup.rb', 'test')
		
	end	


  #######################################

end # namespace :setup
