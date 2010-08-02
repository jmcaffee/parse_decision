##############################################################################
# File:: test_context.rb
# Purpose:: Test PDContext class functionality
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

require 'parser'

class  TestPDContext < Test::Unit::TestCase #(3)
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
# test_pdcontext_ctor - Test the constructor
#
#------------------------------------------------------------------------------------------------------------#
  def test_pdcontext_ctor
    target = PDContext.new
    
    assert(nil != target)
  end

  
  def test_pdcontext_data
    ctx 	= PDContext.new
    target 	= :testVal
	expected = "This is a Test Value"
    
	ctx[target] = expected
	
    assert(ctx[target] == expected)
  end

  
  def test_pdcontext_nil_data
    ctx 	= PDContext.new
    target 	= :testVal
	
    assert(ctx[target].nil?)
  end

  
  def test_pdcontext_set_parsemode
    ctx 	= PDContext.new
    target 	= :webdecision
	
	ctx.parseMode = target
    assert(ctx.parseMode == target)
  end

  
  def test_pdcontext_set_invalid_parsemode
    ctx 	= PDContext.new
    target 	= :badMode
	expected = :default
	
	ctx.parseMode = expected
	ctx.parseMode = target
    assert(ctx.parseMode == expected)
  end

  
  
#-------------------------------------------------------------------------------------------------------------#
# test_pdcontext_does_something
#
#------------------------------------------------------------------------------------------------------------#
  def test_pdcontext_does_something
    
  end
  

end # TestPDContext
