##############################################################################
# File:: unInstall.rb
# Purpose:: Remove all parsedecision files from the ruby directories.
# 
# Author::    Jeff McAffee 03/12/2010
# Copyright:: Copyright (c) 2010, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'fileutils'
require 'find'
include FileUtils

$PROJNAME = 'parsedecision'

class Uninstaller

  def initialize()
    @gemsBinDir = "#{ENV['SYS_TOOLS_DRV']}/ruby/bin"
    @gemsLibDir = "#{ENV['SYS_TOOLS_DRV']}/ruby/lib/ruby/site_ruby/1.8"
  end
  

  def buildFileList(srcDir)
    files = Dir.glob(File.join(srcDir, "*"))
    dirs = []
    files.each do |f|
      dirs << f if(File.directory?(f))
    end
    dirs.each do |d|    # Remove directories from the file list.
      files.delete d
    end
    files
  end


  def buildDirList(srcDir)
    dirs = []
    ignoreDirs = ['.svn']
    
    Find.find(srcDir) do |entry|
      if FileTest.directory?(entry)
        if (File.basename(entry)[0] == ?. || ignoreDirs.include?(File.basename(entry)))
          Find.prune
        else
          dirs << entry
        end
      end
    end
    
    dirs.delete srcDir    # Remove the source directory (user already knows about it).
    dirs
  end


  def setBasePath(pathList, basePath)
    newPathList = []
    pathList.each do |f|
      newPathList << File.join(basePath, File.basename(f))
    end
    newPathList
  end
  
  
  def dumpArray(ar)
    ar.each do |i|
      puts "#{i}"
    end
  end
  
  
  def deleteBinFiles()
    projBinPath = File.join(File.dirname(__FILE__), "bin")
    tmpBinFiles = buildFileList(projBinPath)
    binFiles = setBasePath(tmpBinFiles, @gemsBinDir)
    rm_rf binFiles
    #dumpArray binFiles
  end


  def deleteLibFiles
    projLibPath = File.join(File.dirname(__FILE__), "lib")
    tmpLibFiles = buildFileList(projLibPath)
    libFiles = setBasePath(tmpLibFiles, @gemsLibDir)
    tmpLibDirs = buildDirList(projLibPath)
    libDirs = setBasePath(tmpLibDirs, @gemsLibDir)
    
    rm_rf libFiles
    #dumpArray libFiles
    rm_rf libDirs
    #dumpArray libDirs
  end

  
  def execute()
    deleteBinFiles()
    deleteLibFiles()
  end


end # class Uninstaller

  
if $0 == __FILE__
    Uninstaller.new.execute
end    
