######################################################################################
# File:: rakefile
# Purpose:: Build tasks for ParseDecision application
#
# Author::    Jeff McAffee 03/12/2010
# Copyright:: Copyright (c) 2010, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
######################################################################################

require 'rake'
require 'rake/clean'
require 'rake/rdoctask'
require 'ostruct'
require 'rakeUtils'

# Setup common directory structure


PROJNAME        = "ParseDecision"

# Setup common clean and clobber targets

#CLEAN.include("#{BUILDDIR}/**/*.*")
#CLOBBER.include("#{BUILDDIR}")


#directory BUILDDIR

$verbose = true
	

#############################################################################
#### Imports
# Note: Rake loads imports only after the current rakefile has been completely loaded.

# Load local tasks.
imports = FileList['tasks/**/*.rake']
imports.each do |imp|
	puts "Importing local task file: #{imp}" if $verbose
	import "#{imp}"
end



#############################################################################
#task :init => [BUILDDIR] do
task :init do

end


#############################################################################
Rake::RDocTask.new do |rdoc|
    files = ['docs/**/*.rdoc', 'lib/**/*.rb', 'app/**/*.rb']
    rdoc.rdoc_files.add( files )
    rdoc.main = "docs/README.rdoc"           	# Page to start on
	#puts "PWD: #{FileUtils.pwd}"
    rdoc.title = "#{PROJNAME} Documentation"
    rdoc.rdoc_dir = 'doc'                   # rdoc output folder
    rdoc.options << '--line-numbers' << '--inline-source' << '--all'
end


#############################################################################
task :incVersion do
    ver = VersionIncrementer.new
    ver.incBuild( "#{APPNAME}.ver" )
    ver.writeSetupIni( "setup/VerInfo.ini" )
    $APPVERSION = ver.version
end

