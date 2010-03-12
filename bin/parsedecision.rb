##############################################################################
# File:: parsedecision.rb
# Purpose:: Utility to ...
# 
# Author::    Jeff McAffee 03/12/2010
# Copyright:: Copyright (c) 2010, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'parsedecision'
require 'user-choices'


class ParseDecisionApp < UserChoices::Command
    include UserChoices

    
    def initialize()
        super
        @controller = parsedecisionController.new
    end
    
    
    def add_sources(builder)
        builder.add_source(CommandLineSource, :usage,
                            "Usage: #{$0} [options] CMDLINE_ARG",
                            "Application description",
                            "CMDLINE_ARG restrictions/description.")
    end # def add_sources
    
    
    def add_choices(builder)
        # Arguments
        #builder.add_choice(:cmdArg, :length=>1) { |command_line|   # Use length to REQUIRE args.
        builder.add_choice(:cmdArg) { |command_line|
            command_line.uses_arglist
        }
        
        # Switches
        builder.add_choice(:aswitch, :type=>:boolean, :default=>false) { |command_line|
            command_line.uses_switch("-a", "--aswitch",
                                    "Switch description.")
        }
        
        # Options
        builder.add_choice(:option, :type=>:string) { |command_line|
            command_line.uses_option("-o", "--option ARG",
                                    "Option description.")
        }
        
    end # def add_choices
    
    
    # Execute the ParseDecision application.
    # This method is called automatically when 'parsedecision(.rb)' is executed from the command line.
    def execute
      $LOG.debug "ParseDecisionApp::execute"

      if(@user_choices[:aswitch])
        @controller.doSomethingWithSwitch(@user_choices[:aswitch])
        return
      end
      
      if(@user_choices[:cmdArg].empty?) # If no cmd line arg...
        @controller.noCmdLineArg()
        return
      end
      
      result = @controller.doSomethingWithCmdLineArg(@user_choices[:cmdArg])
      
      @controller.doSomething()
    end # def execute
        
    
end # class ParseDecisionApp


if $0 == __FILE__
    ParseDecisionApp.new.execute
end    
