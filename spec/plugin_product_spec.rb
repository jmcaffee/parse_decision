require "spec_helper"

def start_product_element(name)
  '<PRODUCTS><PRODUCT Name="'+name+'"'
end

describe "Plugin::Product" do

  ppm_start_string  = "<PARAMS><_DATA_SET"
  rule_start_string = "<Rules>"
  rule_end_string   = "</Decision>"
  end_string        = '</Decision>'

  context "when #execute is called" do

    # Can't use #let here. We want the same plugin to be used so it's
    # updated as we move through the flow.
    plug = ParseDecision::Plugin::Product.new

    context "with a current state of :app" do
      # Can't use #let here. We want the same context to be used so it's
      # updated as we move through the flow.
      ctx = create_context( :app )

      context "with line containing '#{start_product_element('Test')}'" do
        let (:line) { start_product_element('Test') }

        it "returns true and state should change to :productXml" do

          result = plug.execute( ctx, line )

          result.should eq true
          ctx.state.should eq :productXml
        end

        context "with a current state of :productXml" do

          context "with line containing '#{ppm_start_string}'" do
            let (:line) { ppm_start_string }

            it "returns true and state should change to :productPpms" do
              result = plug.execute( ctx, line )

              result.should eq true
              ctx.state.should eq :productPpms
            end

            context "with a current state of :productPpms" do

              context "with line containing '#{rule_start_string}'" do
                let (:line) { rule_start_string }

                it "returns true and state should change to :productRules" do
                  result = plug.execute( ctx, line )

                  result.should eq true
                  ctx.state.should eq :productRules
                end

                context "then plugin will accept all lines" do
                  let (:line) { "any old line" }

                  it "returns true and state should not change" do
                    result = plug.execute( ctx, line )

                    result.should eq true
                    ctx.state.should eq :productRules
                  end # it "returns true and state should not change"

                  context "until it receives '#{rule_end_string}'" do
                    let (:line) { rule_end_string }

                    it "returns true and state should change to :app" do
                      result = plug.execute( ctx, line )

                      result.should eq true
                      ctx.state.should eq :app
                    end # it "returns true and state should change to :app"
                  end # context "until it receives '#{rule_end_string}'"
                end # context "then plugin will accept all lines"
              end # context "with line containing '#{rule_start_string}'"
            end # context "with a current state of :productPpms"
          end # context "with line containing '#{ppm_start_string}'"
        end # context "with a current state of :productXml"
      end # context "with line containing '#{start_product_element('Test')}'"

      context "with line containing anything else" do
        ctx = create_context( :app )
        let (:line) { "blahblahblah" }

        it "should return false and not change state" do
          result = plug.execute( ctx, line )

          result.should eq false
          ctx.state.should eq :app
        end
      end # context "with line containing anything else"
    end # context "with a current state of :app"
  end # context "when #execute is called"

=begin
      context "with line containing '#{end_string}'" do
        Given (:line) { "#{end_string}blahblahblah" }

        When (:result) { plug.execute( ctx, line ) }

        Then { result.should eq true }

        context "and context state will change to :app" do
          Then { ctx.state.should eq :app }
        end
      end
    end
  end
=end
end # describe "Plugin::Product"

