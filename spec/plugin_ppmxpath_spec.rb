require "spec_helper"

describe "Plugin::PpmXpath" do

  def a_context( _state=nil )
    ctx = ParseDecision::PDContext.new
    ctx.outdir = 'tmp/spec'
    ctx.state = _state
    ctx
  end

  start_string = '*APP XPATH xml*'
  end_string = '<PPXPATH>'

  context "when #execute is called" do

    Given (:context) { a_context }
    Given (:plug) { ParseDecision::Plugin::PpmXpath.new }

    context "with a current state of :app" do
      Given (:context) { a_context( :app ) }

      context "with line containing '#{start_string}'" do
        Given (:line) { start_string }

        When (:result) { plug.execute( context, line ) }

        Then { result.should eq true }

        context "and context state will change" do
          Then { context.state.should eq :appPpmXpath }
        end
      end

      context "any other lines are refused" do
        Given (:line) { "anything other than start_string" }
        Given! (:start_state) { context.state }

        When (:result) { plug.execute( context, line ) }

        Then { result.should eq false }

        context "and context state will not change" do
          Then { context.state.should eq start_state }
        end
      end
    end

    context "with a current state of :appPpmXpath" do
      Given (:context) { a_context( :appPpmXpath ) }

      context "accept any line without #{end_string}" do
        Given (:line) { "anything" }

        When (:result) { plug.execute( context, line ) }

        Then { result.should eq true }
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

