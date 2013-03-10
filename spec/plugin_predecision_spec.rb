require "spec_helper"

def start_decision_element(name)
  '<Decision GuidelineId="123" GuidelineName="'+name+'"'
end

describe "Plugin::PreDecisionGuideline" do

  ppms_string = '<PARAMS><_DATA_SET'
  gdl_string = '<Guideline '
  end_string = '</Decision>'

  context "when #execute is called" do

    Given (:context) { create_context }
    Given (:plug) { ParseDecision::Plugin::PreDecisionGuideline.new }

    context "with a current state of :app" do
      Given (:context) { create_context( :app ) }
      Given! (:start_state) { context.state }

      context "with line containing '#{ppms_string}'" do
        Given (:line) { ppms_string }

        When (:result) { plug.execute( context, line ) }

        Then { result.should eq true }

        context "and context state will not change" do
          Then { context.state.should eq start_state }
        end
      end

      context "with line containing '#{gdl_string}'" do
        Given (:line) { "#{gdl_string}blahblahblah" }

        When (:result) { plug.execute( context, line ) }

        Then { result.should eq true }

        context "and context state will change to :preDecisionGdl" do
          Then { context.state.should eq :preDecisionGdl }
        end
      end
    end

    context "with a current state of :preDecisionGdl" do
      Given (:context) { create_context( :preDecisionGdl ) }

      context "accept any line" do
        Given (:line) { "anything" }

        When (:result) { plug.execute( context, line ) }

        Then { result.should eq true }
      end

      context "creates filename from Decision element's GuidelineName attribute" do
        Given (:line) { "#{start_decision_element('TestGdl')} blahblahblah" }

        When (:result) { plug.execute( context, line ) }

        Then { result.should eq true }
        Then { plug.outfile.should eq "00-TestGdl-Rules.xml" }
      end

      context "stop accepting lines after #{end_string} received" do
        Given (:line) { end_string }

        When (:result) { plug.execute( context, line ) }

        Then { result.should eq true }

        context "and context state will change to :app" do
          Then { context.state.should eq :app }
        end
      end
    end
  end
end

