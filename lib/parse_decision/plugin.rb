##############################################################################
# File:: plugin.rb
# Purpose:: Plugin objects for ParseDecision utility
#
# Author::    Jeff McAffee 04/17/2010
# Copyright:: Copyright (c) 2010, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

#############################################################
#   Stage Change Flow
#
# default mode:
#   :app
#     :appPpmXpath
#       :preDecisionGdl
#         :productXpath
#           :productXml
#             :productPpms
#               :productRules
#
# webdecision mode:
#   :app
#     :gdlRules
#       :productRules
#         :decisionResponse
#           :preDecisionGdl
#
#
#
#
#############################################################


##############################################################################
module ParseDecision

##############################################################################
  module Plugin

  end # module Plugin
end # module ParseDecision

require_relative 'plugin/plugin'
require_relative 'plugin/application'
require_relative 'plugin/ppm_xpath'
require_relative 'plugin/pre_decision_guideline'
require_relative 'plugin/product'
require_relative 'plugin/product_xpath'
require_relative 'plugin/web_product'
