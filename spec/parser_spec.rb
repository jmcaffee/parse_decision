require 'spec_helper'

describe ParseDecision::Parser do

  let(:outdir) { 'tmp/spec' }
  let(:parser) { ParseDecision::Parser.new }

  before :each do
    out = Pathname.new outdir
    out.rmtree if out.exist? && out.directory?
  end

  it "returns a version" do
    parser.version.should eq "0.0.2"
  end

  it "raises an error if an output dir is not set" do
    expect { parser.parseFile('spec/data/wf-decision.txt') }.to raise_error("outdir missing")
  end

  let(:product) { 'tmp/spec/01-WF-DataClearing-Pre-Rules.xml' }
  let(:app) { 'tmp/spec/01-APP.xml' }
  let(:decision) { 'tmp/spec/wf-decision.txt' }
  let(:product_file) { Pathname.new product }
  let(:app_file) { Pathname.new app }
  let(:decision_file) { Pathname.new decision }

  it "parses a file" do
    parser.parse 'spec/data/wf-decision.txt', 'tmp/spec'

    product_file.exist?.should be_true
    app_file.exist?.should be_true
    decision_file.exist?.should be_true
  end

  describe "parsed output" do
    let(:output) do
      dump = String.new
      File.open(product) do |f|
        f.each_line {|line| dump << line}
      end
      dump
    end

    it "contains rules" do
      parser.parse 'spec/data/wf-decision.txt', 'tmp/spec'

      output.should include 'CURRENT LOAN STAGE'
      output.should include '<Rule Name='
    end
  end
end
