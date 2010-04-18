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
        @controller = Controller.new
    end
    
    
    def add_sources(builder)
        builder.add_source(CommandLineSource, :usage,
                            "Usage: #{File.basename($0)} [options] [OUTPUT_DIR]",
                            "\n\tParseDecision is used to break decision log files out into their parts.",
                            "\tOUTPUT_DIR [optional] Dir to place generated files.")
    end # def add_sources
    
    
    def add_choices(builder)
        # Arguments
        #builder.add_choice(:cmdArg, :length=>1) { |command_line|   # Use length to REQUIRE args.
        builder.add_choice(:cmdArg) { |command_line|
            command_line.uses_arglist
        }
        
        # Switches
        #builder.add_choice(:aswitch, :type=>:boolean, :default=>false) { |command_line|
        #    command_line.uses_switch("-a", "--aswitch",
        #                            "Switch description.")
        #}

        builder.add_choice(:logging, :type=>:boolean, :default=>false) { |command_line|
            command_line.uses_switch("--logging",
                                    "Turn logging to file on/off.")
        }
        
        builder.add_choice(:reset, :type=>:boolean, :default=>false) { |command_line|
            command_line.uses_switch("-r", "--reset",
                                    "Reset config file to defaults.")
        }
        
        builder.add_choice(:verbose, :type=>:boolean, :default=>false) { |command_line|
            command_line.uses_switch("-v", "--verbose",
                                    "Lots of output.")
        }
        
        builder.add_choice(:version, :type=>:boolean, :default=>false) { |command_line|
            command_line.uses_switch("--version",
                                    "Application version.")
        }
        
        builder.add_choice(:which, :type=>:boolean, :default=>false) { |command_line|
            command_line.uses_switch("--which",
                                    "Display the Application's location.\n")
        }
        
        # Options
        builder.add_choice(:file, :type=>:string) { |command_line|
            command_line.uses_option("-f", "--file ARG",
                                    "Name of decision file","(default: 2.decision.txt)")
        }
        
        builder.add_choice(:outdir, :type=>:string) { |command_line|
            command_line.uses_option("-o", "--outdir ARG",
                                    "Dir to place generated files in.", "(Will be created if it doesn't exist)")
        }
        
        builder.add_choice(:srcdir, :type=>:string) { |command_line|
            command_line.uses_option("-s", "--srcdir ARG",
                                    "Dir of src decision file.")
        }
        
    end # def add_choices
    
    
    # Execute the ParseDecision application.
    # This method is called automatically when 'parsedecision(.rb)' is executed from the command line.
    def execute
      $LOG.debug "ParseDecisionApp::execute"

      if(@user_choices[:logging])
		@controller.setUserSwitch(:logging, @user_choices[:logging])
		return
	  else
		@controller.setUserSwitch(:logging, false)
      end
      
      if(@user_choices[:reset])
        @controller.setUserSwitch(:reset, @user_choices[:reset])
        return
      end
      
      if(@user_choices[:verbose])
        @controller.setUserSwitch(:verbose, @user_choices[:verbose])
      end
      
      if(@user_choices[:version])
        @controller.setUserSwitch(:version, @user_choices[:version])
        return
      end
      
      if(@user_choices[:which])
        puts "Location: #{$0}"
        return
      end
      
      if(@user_choices[:file])
        @controller.setUserOption(:file, @user_choices[:file])
      end
      
      if(@user_choices[:outdir])
        @controller.setUserOption(:outdir, @user_choices[:outdir])
      end
      
      if(@user_choices[:srcdir])
        @controller.setUserOption(:srcdir, @user_choices[:srcdir])
      end
      
      if(@user_choices[:cmdArg].empty?) # If no cmd line arg...
        if( !@controller.noCmdLineArg() )
			return
		end
      else
		  if( !@controller.doSomethingWithCmdLineArg(@user_choices[:cmdArg]) )
			return
		  end
	  end
      
      @controller.doSomething()
    end # def execute
        
    
end # class ParseDecisionApp


if $0 == __FILE__
    ParseDecisionApp.new.execute
end    
