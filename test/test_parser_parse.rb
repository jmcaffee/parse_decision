##############################################################################
# File:: test_parser_parse.rb
# Purpose:: Test ParseDecision::Parser.parse functionality
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

require 'parse_decision'

class  TestParserParse < Test::Unit::TestCase #(3)
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
    @outputDir = File.join(@dataDir, "output")
    
  end
  
#-------------------------------------------------------------------------------------------------------------#
# teardown - Clean up test fixture
#
#------------------------------------------------------------------------------------------------------------#
  def teardown
  end
  
#-------------------------------------------------------------------------------------------------------------#
# cleanOutput - Clean up output directory
#
#------------------------------------------------------------------------------------------------------------#
  def cleanOutput
	if(!File.exists?(@outputDir))
		FileUtils.mkdir(@outputDir)
		return
	end

	if(File.directory?(@outputDir))
		FileUtils.rm_r(@outputDir)
		FileUtils.mkdir(@outputDir)
	end

	
  end
  
#-------------------------------------------------------------------------------------------------------------#
# test_parsedecision_parse - Test the parseFile function
#
#------------------------------------------------------------------------------------------------------------#
  def DUPtest_parsedecision_parse
    target = Parser.new
    assert(nil != target)

	fname = "2.decision.txt"
	srcFile = File.join(@dataDir, fname)
    assert(File.exists?(srcFile))

	target.parseFile(srcFile)
  end

#-------------------------------------------------------------------------------------------------------------#
# test_parsedecision_parse - Test the parseFile function
#
#------------------------------------------------------------------------------------------------------------#
  def test_parsedecision_parse
    target = Parser.new
    assert(nil != target)

	fname = "2.decision.txt"
	srcFile = File.join(@dataDir, fname)
    assert(File.exists?(srcFile))

	cleanOutput()

	target.setOutdir(@outputDir)
	target.parseFile(srcFile)
	
	assert(File.exists?(File.join(@outputDir, "01-APP.xml")))
	assert(File.exists?(File.join(@outputDir, "01-Mod-Forbear-PRODUCT.xml")))
	assert(File.exists?(File.join(@outputDir, "01-Mod-Forgive-PRODUCT.xml")))
	assert(File.exists?(File.join(@outputDir, "01-Mod-RateTerm-PRODUCT.xml")))
	assert(File.exists?(File.join(@outputDir, "01-Mod-SAM-PRODUCT.xml")))
  end

#-------------------------------------------------------------------------------------------------------------#
# test_parsedecision_does_something
#
#------------------------------------------------------------------------------------------------------------#
  def test_parsedecision_does_something
    
  end
  

end # TestParserParse
