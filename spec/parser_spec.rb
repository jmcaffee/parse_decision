require 'spec_helper'

describe ParseDecision::Parser do

    let(:parser) { ParseDecision::Parser.new }
    let(:outdir) { 'tmp/spec' }
    let(:wfsrc_log) { 'spec/data/wf.decision.txt' }

    before :each do
      out = Pathname.new outdir
      out.rmtree if out.exist? && out.directory?
    end

  it "returns a version" do
    parser.version.should eq "0.0.3"
  end

  it "raises an error if an output dir is not set" do
    expect { parser.parseFile(wfsrc_log) }.to raise_error("outdir missing")
  end

    let(:wfrules_output)  { 'tmp/spec/01-WF-DataClearing-Pre-Rules.xml' }
    let(:wfapp_output)    { 'tmp/spec/01-APP.xml' }
    let(:wflog_output)    { 'tmp/spec/wf.decision.txt' }

    let(:wfrules_file)    { Pathname.new wfrules_output }
    let(:wfapp_file)      { Pathname.new wfapp_output }
    let(:wfsource_file)   { Pathname.new wflog_output }

  it "parses a file" do
    parser.parse wfsrc_log, outdir

    wfrules_file.exist?.should be_true
    wfapp_file.exist?.should be_true
    wfsource_file.exist?.should be_true
  end

  describe "parsed workflow decisions" do

      # Reference files
      let(:wfapp_reference)     { 'spec/data/reference/workflow/01-APP.xml' }
      let(:wfrules_reference)   { 'spec/data/reference/workflow/01-WF-DataClearing-Pre-Rules.xml' }

      let(:wfrules_result)      { file_to_array( wfrules_output ) }
      let(:wfapp_result)        { file_to_array( wfapp_output ) }
      let(:wf_ref_file)         { file_to_array( wfrules_reference ) }
      let(:wfapp_ref_file)      { file_to_array( wfapp_reference ) }

    it "contain rules" do
      parser.parse wfsrc_log, outdir

      wfrules_result.should include 'CURRENT LOAN STAGE'
      wfrules_result.should include '<Rule Name='
    end

    it "match reference output files" do
      parser.parse wfsrc_log, outdir

      wfrules_result.should eq wf_ref_file
      wfapp_result.should eq wfapp_ref_file
    end
  end

  describe "parsed product decisions" do

    let(:src_log)       { 'spec/data/prod.decision.txt' }

    let(:log_output)    { 'tmp/spec/prod.decision.txt' }
    let(:app_output)    { 'tmp/spec/02-APP.xml' }
    let(:rules_output)  { 'tmp/spec/02-FAPIILoanModification-PRODUCT.xml' }

      # Reference files
      let(:app_reference)     { 'spec/data/reference/product/02-APP.xml' }
      let(:rules_reference)   { 'spec/data/reference/product/02-FAPIILoanModification-PRODUCT.xml' }

      let(:app_result)        { file_to_array( app_output ) }
      let(:rules_result)      { file_to_array( rules_output ) }
      let(:app_ref_file)      { file_to_array( app_reference ) }
      let(:rules_ref_file)    { file_to_array( rules_reference ) }

    it "contain rules" do
      parser.parse src_log, outdir

      app_result.should include '<DECISION_REQUEST>'
      rules_result.should include '<Rule Name='
    end

    it "match reference output files" do
      parser.parse src_log, outdir

      app_result.should eq app_ref_file
      rules_result.should eq rules_ref_file
    end

  end

  describe "parsed validation decisions" do

    let(:src_log)       { 'spec/data/prod.decision.txt' }

    let(:log_output)    { 'tmp/spec/prod.decision.txt' }
    let(:app_output)    { 'tmp/spec/01-APP.xml' }
    let(:rules_output)  { 'tmp/spec/01-Validation-Rules.xml' }

      # Reference files
      let(:app_reference)     { 'spec/data/reference/product/01-APP.xml' }
      let(:rules_reference)   { 'spec/data/reference/product/01-Validation-Rules.xml' }

      let(:app_result)        { file_to_array( app_output ) }
      let(:rules_result)      { file_to_array( rules_output ) }
      let(:app_ref_file)      { file_to_array( app_reference ) }
      let(:rules_ref_file)    { file_to_array( rules_reference ) }

    it "contain rules" do
      parser.parse src_log, outdir

      app_result.should include '<DECISION_REQUEST>'
      rules_result.should include '<Rule Name='
    end

    it "match reference output files" do
      parser.parse src_log, outdir

      app_result.should eq app_ref_file
      rules_result.should eq rules_ref_file
    end

  end

end
