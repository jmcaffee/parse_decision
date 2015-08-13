######################################################################################
# File:: rakefile
# Purpose:: Build tasks for ParseDecision application
#
# Author::    Jeff McAffee 03/12/2010
# Copyright:: Copyright (c) 2010, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
######################################################################################

require 'rubygems'
require 'rubygems/package_task'
require 'psych'
gem 'rdoc', '>= 3.9.4'

require 'rake'
require 'rake/clean'
require 'rdoc/task'
require 'ostruct'
#require 'rakeUtils'



# Set the project name
PROJNAME        = "ParseDecision"

# Bring in the library's version constant
$:.unshift File.expand_path("../lib", __FILE__)
require "parse_decision/version"

PKG_VERSION = ParseDecision::VERSION
PKG_FILES   = Dir["**/*"].select { |d| d =~ %r{^(README|bin/|data/|ext/|lib/|spec/|test/)} }

# Setup common clean and clobber targets ----------------------------

#CLEAN.include("#{BUILDDIR}/**/*.*")
#CLOBBER.include("#{BUILDDIR}")

# Setup common directory structure ----------------------------------

#directory BUILDDIR

#$verbose = true


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
desc "Documentation for building gem"
task :help do
  hr = "-"*79
  puts hr
  puts "Building the Gem"
  puts "================"
  puts
  puts "Use the following command line to build and install the gem"
  puts
  puts "on *nix"
  puts "rake clean gem && gem install pkg/#{PROJNAME.downcase}-#{PKG_VERSION}.gem -l --no-ri --no-rdoc"
  puts
  puts "on *doze"
  puts "rake clean gem && gem install pkg\\#{PROJNAME.downcase}-#{PKG_VERSION}.gem -l --no-ri --no-rdoc"
  puts
  puts "See also the build_gem_script task which will create a script to build and install the gem."
  puts
  puts hr
end


#############################################################################
desc "Generate a simple script to build and install this gem"
task :build_gem_script do
  # For windows
  scriptname = "buildgem.cmd"
  if(File.exists?(scriptname))
    puts "Removing existing script."
    rm scriptname
  end

  File.open(scriptname, 'w') do |f|
    f << "::\n"
    f << ":: #{scriptname}\n"
    f << "::\n"
    f << ":: Running this script will generate and install the #{PROJNAME} gem.\n"
    f << ":: Run 'rake build_gem_script' to regenerate this script.\n"
    f << "::\n"

    f << "rake clean gem && gem install pkg\\#{PROJNAME.downcase}-#{PKG_VERSION}.gem -l --no-ri --no-rdoc\n"
  end

  # For nix
  scriptname = "buildgem"
  if(File.exists?(scriptname))
    puts "Removing existing script."
    rm scriptname
  end

  File.open(scriptname, 'w') do |f|
    f << "#\n"
    f << "# #{scriptname}\n"
    f << "#\n"
    f << "# Running this script will generate and install the #{PROJNAME} gem.\n"
    f << "# Run 'rake build_gem_script' to regenerate this script.\n"
    f << "#\n"

    f << "rake clean gem && gem install pkg/#{PROJNAME.downcase}-#{PKG_VERSION}.gem -l --no-ri --no-rdoc\n"
  end

end


#############################################################################
RDoc::Task.new(:rdoc) do |rdoc|
    files = ['README.rdoc', 'docs/**/*.rdoc', 'lib/**/*.rb', 'bin/**/*']
    rdoc.rdoc_files.add( files )
    # Page to start on
    rdoc.main = "README.md"
  #puts "PWD: #{FileUtils.pwd}"
    rdoc.title = "#{PROJNAME} Documentation"
    rdoc.rdoc_dir = 'doc'                   # rdoc output folder
    rdoc.options << '--line-numbers' << '--all'
end


#############################################################################
desc "List files to be included in gem"
task :pkg_list do
  puts "PKG_FILES (will be included in gem):"
  PKG_FILES.each do |f|
    puts "  #{f}"
  end
end


#############################################################################
spec = Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.summary = "AMS Decision Log Parser"
  s.name = PROJNAME.downcase
  s.version = PKG_VERSION
  s.requirements << 'none'
  s.bindir = 'bin'
  s.require_path = 'lib'
  #s.autorequire = 'rake'
  s.files = PKG_FILES
  s.executables = "parse_decision"
  s.author = "Jeff McAffee"
  s.email = "gems@ktechdesign.com"
  s.homepage = "https://github.com/jmcaffee/parse_decision"
  s.description = <<EOF
ParseDecision parses AMS decision logs.
EOF
end


#############################################################################
Gem::PackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true

  puts "PKG_VERSION: #{PKG_VERSION}"
end


#############################################################################
desc "Run all tests"
task :test => [:init] do
  unless File.directory?('test')
    $stderr.puts 'no test in this package'
    return
  end
  $stderr.puts 'Running tests...'
  TESTDIR = "test"
  begin
    require 'test/unit'
  rescue LoadError
    $stderr.puts 'test/unit cannot loaded.  You need Ruby 1.8 or later to invoke this task.'
  end

  $LOAD_PATH.unshift("./")
  $LOAD_PATH.unshift(TESTDIR)
  Dir[File.join(TESTDIR, "*.rb")].each {|file| require File.basename(file) }
  require 'minitest/autorun'
end


