require 'spec_helper'

describe ParseDecision::Parser do

    let(:parser) { ParseDecision::Parser.new }
    let(:outdir) { 'tmp/spec/parser' }
    let(:wfsrc_log) { 'spec/data/wf.decision.txt' }

    before :each do
      out = Pathname.new outdir
      out.rmtree if out.exist? && out.directory?
    end

  it "raises an error if an output dir is not set" do
    expect { parser.parseFile(wfsrc_log) }.to raise_error("outdir missing")
  end

    let(:wfrules_output)  { outdir+'/001-WF-DataClearing-Pre-Rules.xml' }
    let(:wfapp_output)    { outdir+'/001-APP.xml' }
    let(:wflog_output)    { outdir+'/wf.decision.txt' }

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
      let(:wfapp_reference)     { 'spec/data/reference/workflow/001-APP.xml' }
      let(:wfrules_reference)   { 'spec/data/reference/workflow/001-WF-DataClearing-Pre-Rules.xml' }

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

    let(:log_output)    { outdir+'/prod.decision.txt' }
    let(:app_output)    { outdir+'/002-APP.xml' }
    let(:rules_output)  { outdir+'/002-FAPIILoanModification-PRODUCT.xml' }

      # Reference files
      let(:app_reference)     { 'spec/data/reference/product/002-APP.xml' }
      let(:rules_reference)   { 'spec/data/reference/product/002-FAPIILoanModification-PRODUCT.xml' }

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

    let(:log_output)    { outdir+'/prod.decision.txt' }
    let(:app_output)    { outdir+'/001-APP.xml' }
    let(:rules_output)  { outdir+'/001-Validation-Rules.xml' }

      # Reference files
      let(:app_reference)     { 'spec/data/reference/product/001-APP.xml' }
      let(:rules_reference)   { 'spec/data/reference/product/001-Validation-Rules.xml' }

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

  describe "parsed workflow2 decisions" do

    let(:src_log)       { 'spec/data/wf2.decision.txt' }

    let(:log_output)    { outdir+'/wf2.decision.txt' }
    let(:app_output)    { outdir+'/001-APP.xml' }
    let(:rules_output)  { outdir+'/001-WF-ProdSel-Post-Rules.xml' }

      # Reference files
      let(:app_reference)     { 'spec/data/reference/workflow-2/001-APP.xml' }
      let(:rules_reference)   { 'spec/data/reference/workflow-2/001-WF-ProdSel-Post-Rules.xml' }

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

  describe "parsed multi-product decisions" do

    let(:src_log)       { 'spec/data/multiproduct.decision.txt' }

    let(:app_output)    { outdir+'/001-APP.xml' }
    let(:rules_output1) { outdir+'/001-Mod-Forbear-PRODUCT.xml' }
    let(:rules_output2) { outdir+'/001-Mod-Forgive-PRODUCT.xml' }
    let(:rules_output3) { outdir+'/001-Mod-RateTerm-PRODUCT.xml' }
    let(:rules_output4) { outdir+'/001-Mod-SAM-PRODUCT.xml' }
    let(:log_output)    { outdir+'/multiproduct.decision.txt' }

      # Reference files
      let(:app_reference)     { 'spec/data/reference/multiproduct/001-APP.xml' }
      let(:rules_reference1)  { 'spec/data/reference/multiproduct/001-Mod-Forbear-PRODUCT.xml' }
      let(:rules_reference2)  { 'spec/data/reference/multiproduct/001-Mod-Forgive-PRODUCT.xml' }
      let(:rules_reference3)  { 'spec/data/reference/multiproduct/001-Mod-RateTerm-PRODUCT.xml' }
      let(:rules_reference4)  { 'spec/data/reference/multiproduct/001-Mod-SAM-PRODUCT.xml' }

      let(:app_result)        { file_to_array( app_output ) }
      let(:rules_result1)     { file_to_array( rules_output1 ) }
      let(:rules_result2)     { file_to_array( rules_output2 ) }
      let(:rules_result3)     { file_to_array( rules_output3 ) }
      let(:rules_result4)     { file_to_array( rules_output4 ) }
      let(:app_ref_file)      { file_to_array( app_reference ) }
      let(:rules_ref_file1)   { file_to_array( rules_reference1 ) }
      let(:rules_ref_file2)   { file_to_array( rules_reference2 ) }
      let(:rules_ref_file3)   { file_to_array( rules_reference3 ) }
      let(:rules_ref_file4)   { file_to_array( rules_reference4 ) }

    it "contain rules" do
      parser.parse src_log, outdir

      app_result.should include '<DECISION_REQUEST>'
      rules_result1.should include '<Rule Name='
      rules_result2.should include '<Rule Name='
      rules_result3.should include '<Rule Name='
      rules_result4.should include '<Rule Name='
    end

    it "match reference output files" do
      parser.parse src_log, outdir

      app_result.should eq app_ref_file
      rules_result1.should eq rules_ref_file1
      rules_result2.should eq rules_ref_file2
      rules_result3.should eq rules_ref_file3
      rules_result4.should eq rules_ref_file4
    end

  end

  describe "parsed web decisions" do

    let(:src_log)       { 'spec/data/web.decision.txt' }

    let(:app_output1)   { outdir+'/001-APP.xml' }
    let(:app_output2)   { outdir+'/002-APP.xml' }
    let(:rules_output1) { outdir+'/001-Product01-PRODUCT.xml' }
    let(:rules_output2) { outdir+'/002-Product01-PRODUCT.xml' }
    let(:log_output)    { outdir+'/web.decision.txt' }

      # Reference files
      let(:app_reference1)    { 'spec/data/reference/web/001-APP.xml' }
      let(:app_reference2)    { 'spec/data/reference/web/002-APP.xml' }
      let(:rules_reference1)  { 'spec/data/reference/web/001-Product01-PRODUCT.xml' }
      let(:rules_reference2)  { 'spec/data/reference/web/002-Product01-PRODUCT.xml' }

      let(:app_result1)       { file_to_array( app_output1 ) }
      let(:app_result2)       { file_to_array( app_output2 ) }
      let(:rules_result1)     { file_to_array( rules_output1 ) }
      let(:rules_result2)     { file_to_array( rules_output2 ) }
      let(:app_ref_file1)     { file_to_array( app_reference1 ) }
      let(:app_ref_file2)     { file_to_array( app_reference2 ) }
      let(:rules_ref_file1)   { file_to_array( rules_reference1 ) }
      let(:rules_ref_file2)   { file_to_array( rules_reference2 ) }

    it "contain rules" do
      parser.parse src_log, outdir

      app_result1.should include '<DECISION_REQUEST>'
      app_result2.should include '<DECISION_REQUEST>'
      rules_result1.should include '<Rule Name='
      rules_result2.should include '<Rule Name='
    end

    it "match reference output files" do
      parser.parse src_log, outdir

      app_result1.should eq app_ref_file1
      app_result2.should eq app_ref_file2
      rules_result1.should eq rules_ref_file1
      rules_result2.should eq rules_ref_file2
    end

  end

end
