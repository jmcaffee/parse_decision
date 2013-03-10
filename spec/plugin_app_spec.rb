require "spec_helper"

describe "Plugin::Application" do

  def a_context
    ctx = ParseDecision::PDContext.new
    ctx.outdir = 'tmp/spec'
    ctx
  end

  context "when #execute is called" do

    Given (:context) { a_context }
    Given (:plug) { ParseDecision::Plugin::Application.new }
    Given (:line) { '<DECISION_REQUEST><APPLICATION Blah="bleh"/></DECISION_REQUEST>' }

    context "with line containing '<APPLICATION '" do
      When (:result) { plug.execute( context, line ) }

      Then { result.should eq true }

      context "and context state will change" do
        Then { context.state.should eq :app }
      end
    end

    Given(:another_line) { '<Guideline Name="Blargh" />' }

    context "with line that does not contain '<APPLICATION '" do
      When(:result) { plug.execute( context, another_line ) }

      Then { result.should eq false }

      context "and context state will not change" do
        Then { context.state.should eq nil }
      end
    end
  end
end

