##############################################################################
# File:: parsedecision.rb
# Purpose:: Include file for ParseDecision library
#
# Author::    Jeff McAffee 03/12/2010
# Copyright:: Copyright (c) 2010, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'find'
require 'logger'
require 'bundler/setup'


if(!$LOG)
  $LOG = Logger.new(STDERR)
  $LOG.level = Logger::ERROR
end

if ENV["DEBUG"] == '1'
  puts "LOGGING: ON due to DEBUG=1"
  $LOG.level = Logger::DEBUG
end

$LOGGING = false
# Uncomment line below to force logging:
#$LOGGING = true   # TODO: Change this flag to false when releasing production build.

require "#{File.join( File.dirname(__FILE__), 'parsedecision','version')}"
require "#{File.join( File.dirname(__FILE__), 'parsedecision','config')}"

logcfg = ParseDecision::Config.new.load
if(logcfg.key?(:logging) && (true == logcfg[:logging]) )
  $LOGGING = true
end

if($LOGGING)
  # Create a new log file each time:
  file = File.open('parsedecision.log', File::WRONLY | File::APPEND | File::CREAT | File::TRUNC)
  $LOG = Logger.new(file)
  $LOG.level = Logger::DEBUG
  #$LOG.level = Logger::INFO
else
  if(File.exists?('parsedecision.log'))
FileUtils.rm('parsedecision.log')
end
end
$LOG.info "**********************************************************************"
$LOG.info "Logging started for ParseDecision library."
$LOG.info "**********************************************************************"


class_files = File.join( File.dirname(__FILE__), 'parsedecision', '*.rb')
$: << File.join( File.dirname(__FILE__), 'parsedecision')  # Add directory to the include file array.
Dir.glob(class_files) do | class_file |
    require class_file[/\w+\.rb$/]
end


