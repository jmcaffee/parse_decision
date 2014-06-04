##############################################################################
# File:: config.rb
# Purpose:: ParseDecision configuration file reader/writer class.
#
# Author::    Jeff McAffee 03/12/2010
# Copyright:: Copyright (c) 2010, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'ktcommon/ktcfg'
require 'parsedecision/version'

##############################################################################
# Everything is contained in module ParseDecision
module ParseDecision

  ##########################################################################
  # Controller class handles interactions bewteen the view (cmdline script)
  # and the model (Tool).
  class Config < KtCfg::CfgFile

    attr_accessor :cfg

    def initialize(rootDir=nil)
      $LOG.debug "Config::initialize"
      super
      @cfg = {}

      setDefaults()
    end

    def setDefaults
      $LOG.debug "Config::setDefaults"

      # Blow away the existing cfg hash
      @cfg = {}

      # Notes about APPDATA paths:
      # Local app data should be used when an app's data is too
      # big to move around. Or is specific to the machine running
      # the application.
      #
      # Roaming app data files could be pushed to a server (in a
      # domain environment) and downloaded onto a different work
      # station.
      #
      # LocalLow is used for data that must be sandboxed. Currently
      # it is only used by IE for addons and storing data from
      # untrusted sources (as far as I know).
      #


      #appDataPath  = ENV["APPDATA"]          # APPDATA returns AppData\Roaming on Vista/W7
      appDataPath   = ENV["LOCALAPPDATA"]       # LOCALAPPDATA returns AppData\Local on Vista/W7
      appDataPath   ||= ENV["HOME"]
      @cfg[:appPath]  = File.rubypath(File.join(appDataPath, "parsedecision"))
      @cfg[:version]  = ParseDecision::VERSION
      @cfg[:file]   = "2.decision.txt"
      @cfg[:logging]  = false
    end

    # Load the YAML configuration file.
    # returns:: a hash containing configuration info.
    def load
      $LOG.debug "Config::load"

      filepath = cfgFilePath("pdconfig.yml")
      if(!File.exists?( filepath ))   # TODO: This needs to be moved into KtCfg.
        $LOG.debug "Config file does not exist. Returning default config obj."
        return @cfg
      end

      @cfg = read("pdconfig.yml")
    end

    # Save the @cfg hash to a YAML file.
    def save(cfg=nil)
      $LOG.debug "Config::save( cfg )"
      if( nil != cfg )
        @cfg = cfg
      end
      write("pdconfig.yml", @cfg)
    end

    def addKeyValue(key, value)
      $LOG.debug "Config::addKeyValue( #{key.to_s}, #{value} )"
      @cfg[key] = value
    end
  end # class Config
end # module ParseDecision
