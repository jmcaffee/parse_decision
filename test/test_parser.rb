##############################################################################
# File:: test_parser.rb
# Purpose:: Test ParseDecision class functionality
# 
# Author::    Jeff McAffee 03/12/2010
# Copyright:: Copyright (c) 2010, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'test/unit'   #(1)
require 'flexmock/test_unit'
#require 'testhelper/filecomparer'
require 'logger'

require 'fileutils'

require 'parsedecision'

class  TestParser < Test::Unit::TestCase #(3)
    include FileUtils
    include FlexMock::TestCase
	include ParseDecision
	
#-------------------------------------------------------------------------------------------------------------#
# setup - Set up test fixture
#
#------------------------------------------------------------------------------------------------------------#
  def setup
    $LOG = Logger.new(STDERR)
    $LOG.level = Logger::DEBUG
    @baseDir = File.dirname(__FILE__)
    @dataDir = File.join(@baseDir, "data")
    
  end
  
#-------------------------------------------------------------------------------------------------------------#
# teardown - Clean up test fixture
#
#------------------------------------------------------------------------------------------------------------#
  def teardown
  end
  
#-------------------------------------------------------------------------------------------------------------#
# test_parsedecision_ctor - Test the constructor
#
#------------------------------------------------------------------------------------------------------------#
  def test_parsedecision_ctor
    target = Parser.new
    
    assert(nil != target)
  end

#-------------------------------------------------------------------------------------------------------------#
# test_parsedecision_does_something
#
#------------------------------------------------------------------------------------------------------------#
  def test_parsedecision_does_something
    
  end
  

end # TestParser
