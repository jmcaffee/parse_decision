##############################################################################
# File:: testconfig.rb
# Purpose:: Test Config class functionality
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

class  TestConfig < Test::Unit::TestCase #(3)
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
# test_config_ctor - Test the constructor
#
#------------------------------------------------------------------------------------------------------------#
  def test_config_ctor
    target = Config.new(@dataDir)
    
    assert(nil != target)
  end

#-------------------------------------------------------------------------------------------------------------#
# test_config_writes_cfg_file
#
#------------------------------------------------------------------------------------------------------------#
  def test_config_writes_cfg_file
    targetFile = File.join(@dataDir, "pdconfig.yml")
    rm_rf(targetFile) if(File.exists?(targetFile))
    
    target = Config.new(@dataDir)
    target.save
    
    assert(File.exists?(targetFile), "Cfg file not written to disk")
  end
  

#-------------------------------------------------------------------------------------------------------------#
# test_config_reads_cfg_file
#
#------------------------------------------------------------------------------------------------------------#
  def test_config_reads_cfg_file
    targetFile = File.join(@dataDir, "pdconfig.yml")
    rm_rf(targetFile) if(File.exists?(targetFile))
    
    expected = "Test Data"
    helper = Config.new(@dataDir)
    helper.cfg[:appPath] = expected
    helper.save
    helper = nil
    
    target = Config.new(@dataDir)
    target.load
    
    assert(!target.cfg[:appPath].empty?, "Cfg file not read from disk")
    assert(target.cfg[:appPath] == expected, "Cfg file contains incorrect data")
  end
  

end # TestConfig
