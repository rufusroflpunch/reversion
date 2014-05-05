require_relative 'spec_helper'

describe Revert do
  before do
    # Create the file structure for the test

    FileUtils.mkdir_p 'specs/test_files'
    Dir.chdir 'specs/test_files'
    File.open('file1', 'w+') { |f| f.puts "test file 1\n1234" }
    File.open('file2', 'w+') { |f| f.puts "test file 2\nasdf" }

    @repo = Revert.new('.rev/')
    @repo.init_repo
  end

  after do
    Dir.chdir '../..'
    FileUtils.rm_rf 'specs/test_files/'
  end

  it "should be an instance of Revert" do
    @repo.must_be_instance_of Revert
  end

  it "should create the proper directory" do
    File.directory?('.rev').must_equal true
  end

  it "should properly evaluage instance_eval for the manifest" do
    File.open('.rev/manifest', 'w+') { |f| f.puts '@repo_dir' }
    @repo.load_repo.must_equal '.rev/'
  end
end
