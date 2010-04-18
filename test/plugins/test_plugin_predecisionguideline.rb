##############################################################################
# File:: test_plugin_predecisionguideline.rb
# Purpose:: Test Plugin::PreDecisionGuideline class functionality
# 
# Author::    Jeff McAffee 04/18/2010
# Copyright:: Copyright (c) 2010, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'test/unit'   #(1)
require 'flexmock/test_unit'
#require 'testhelper/filecomparer'
require 'logger'

require 'fileutils'

require 'parsedecision'

class  TestPluginPreDecisionGuideline < Test::Unit::TestCase #(3)
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
    @baseDir = File.expand_path(File.join(File.dirname(__FILE__), ".."))
    @dataDir = File.join(@baseDir, "data")
    @outputDir = File.join(@dataDir, "output")
    
    @context = PDContext.new
    assert(nil != @context)

	
  end
  
#-------------------------------------------------------------------------------------------------------------#
# teardown - Clean up test fixture
#
#------------------------------------------------------------------------------------------------------------#
  def teardown
	@context = nil
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
# test_plugin_predecisionguideline_attrib_replacement - Test the Plugin::Product class
#
#------------------------------------------------------------------------------------------------------------#
  def test_plugin_predecisionguideline_attrib_replacement
    plugin = Plugin::PreDecisionGuideline.new
    assert(nil != plugin)

	target = "<PARAMS><_DATA_SET _Name='Test1' _Value='1'/><_DATA_SET _Name='Test2' _Value='2'/><_DATA_SET _Name='Test3' _Value='3'/></PARAMS>"
	expected = "<PARAMS><DATA_SET Name='Test1' Value='1'/><DATA_SET Name='Test2' Value='2'/><DATA_SET Name='Test3' Value='3'/></PARAMS>"
	
	@context.state = :app
	result = plugin.execute( @context, target )
	assert(result, "Product.execute() returned false.")
	
	output = plugin.ppmData
	assert(output == expected, "Output did not match expected.")
	
  end

#-------------------------------------------------------------------------------------------------------------#
# INOPtest_parsedecision_parse - Test the parseFile function
#
#------------------------------------------------------------------------------------------------------------#
  def INOPtest_parsedecision_parse
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
  def test_plugin_product_does_something
    
  end
  

end # TestPluginProduct
