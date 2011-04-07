######################################################################################
# File:: rakefile
# Purpose:: Build tasks for ParseDecision application
#
# Author::    Jeff McAffee 03/12/2010
# Copyright:: Copyright (c) 2010, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
######################################################################################

require 'rubygems'
require 'rake/gempackagetask'

require 'rake'
require 'rake/clean'
require 'rake/rdoctask'
require 'ostruct'
require 'rakeUtils'

# Setup common directory structure


PROJNAME        = "ParseDecision"

$:.unshift File.expand_path("../lib", __FILE__)
require "ppmtogdl/version"

PKG_VERSION	= PpmToGdl::VERSION
PKG_FILES 	= Dir["**/*"].select { |d| d =~ %r{^(README|bin/|data/|ext/|lib/|spec/|test/)} }

# Setup common clean and clobber targets

CLEAN.include("pkg")
CLOBBER.include("pkg")
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


#############################################################################
spec = Gem::Specification.new do |s|
	s.platform = Gem::Platform::RUBY
	s.summary = "AMS Decision Log Parser"
	s.name = PROJNAME.downcase
	s.version = PKG_VERSION
	s.requirements << 'none'
	s.require_path = 'lib'
	#s.autorequire = 'rake'
	s.files = PKG_FILES
	s.executables = "parsedecision"
	s.author = "Jeff McAffee"
	s.email = "gems@ktechdesign.com"
	s.homepage = "http://gems.ktechdesign.com"
	s.description = <<EOF
ParseDecision parses AMS decision dogs.
EOF
end


#############################################################################
Rake::GemPackageTask.new(spec) do |pkg|
	pkg.need_zip = true
	pkg.need_tar = true
	
	puts "PKG_VERSION: #{PKG_VERSION}"
#=begin		
	puts "PKG_FILES:"
	PKG_FILES.each do |f|
		puts "  #{f}"
	end
#=end
end
