require "spec_helper"

describe ParseDecision::PDContext do

  let(:context) { ParseDecision::PDContext.new }

  it "throws an exception if invalid target state is requested" do
    expect { context.state = :notAValidState }.to raise_error("Invalid target state: notAValidState")
  end

  Given(:target_dir) { 'spec/data' }
  Given(:target_file) { 'testfile.txt' }

  context "#src_file sets the source dir and file" do
    When { context.src_file = File.join(target_dir, target_file) }

    Then { context.srcdir.should eq target_dir }
    Then { context.file.should eq target_file }
  end

end # describe ParseDecision::PDContext
