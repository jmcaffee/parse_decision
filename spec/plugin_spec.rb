require 'spec_helper'

describe ParseDecision::Plugin::Plugin do

  let(:plugin)  { ParseDecision::Plugin::Plugin.new }
  let(:context) { ParseDecision::PDContext.new }

    let(:outdir) { 'tmp/spec/plugin' }
    before :each do
      out = Pathname.new outdir
      out.rmtree if out.exist? && out.directory?
      out.mkdir
    end

  it "can be created" do
    plugin.should_not be nil
  end

  it "#execute returns false by default" do
    plugin.execute(context, "").should be_false
  end

  it "#apply_template replaces substrings in a template" do
    template = "Hello <<one>> <<one>> <<two>>"
    pattern = "<<one>>"
    replacement = "cruel"
    output = plugin.apply_template( template, pattern, replacement )
    output.should eq "Hello cruel cruel <<two>>"
  end

  it "#apply_templates replaces substrings provided in a hash" do
    template = "Hello <<one>> <<one>> <<two>>"
    pat1 = "<<one>>"
    pat2 = "<<two>>"
    rep1 = "cruel"
    rep2 = "world"
    output = plugin.apply_templates( template, { pat1 => rep1, pat2 => rep2 } )
    output.should eq "Hello cruel cruel world"
  end

    let(:test_txt)    { outdir+'/test.txt' }
    let(:test_result) { file_to_array( test_txt ) }

  it "#write_to_file will write an array to a file" do
    array = ["one", 'two', "three"]

    File.open(test_txt,'w') do |f|
      plugin.write_to_file f, array
    end

    test_result.should eq array.join
  end
end

