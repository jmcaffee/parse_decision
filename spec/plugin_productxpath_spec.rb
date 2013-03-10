require "spec_helper"

def start_decision_element(name)
  '<Decision GuidelineId="123" GuidelineName="'+name+'"'
end

describe "Plugin::ProductXpath" do

  start_string = '*PRODUCT XPATH xml*'
  end_string = '<PPXPATH>'

  context "when #execute is called" do

    Given (:context) { create_context }
    Given (:plug) { ParseDecision::Plugin::ProductXpath.new }

    context "with a current state of :app" do
      Given (:context) { create_context( :app ) }
      Given! (:start_state) { context.state }

      context "with line containing '#{start_string}'" do
        Given (:line) { start_string }

        When (:result) { plug.execute( context, line ) }

        Then { result.should eq true }

        context "and context state will change to :productXpath" do
          Then { context.state.should eq :productXpath }
        end
      end

      context "with line containing anything else" do
        Given (:line) { "blahblahblah" }

        When (:result) { plug.execute( context, line ) }

        Then { result.should eq false }

        context "and context state will not change" do
          Then { context.state.should eq start_state }
        end
      end
    end

    context "with a current state of :productXpath" do
      Given (:context) { create_context( :productXpath ) }
      Given! (:start_state) { context.state }

      context "accept any line" do
        Given (:line) { "anything" }

        When (:result) { plug.execute( context, line ) }

        Then { result.should eq true }

        context "and context state will not change" do
          Then { context.state.should eq start_state }
        end
      end

      context "with line containing '#{end_string}'" do
        Given (:line) { "#{end_string}blahblahblah" }

        When (:result) { plug.execute( context, line ) }

        Then { result.should eq true }

        context "and context state will change to :app" do
          Then { context.state.should eq :app }
        end
      end
    end
  end
end

