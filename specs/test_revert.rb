require_relative 'spec_helper'

describe Revert do
  before do
    # Create the file structure for the test
    FileUtils.mkdir_p 'specs/test_files'
    Dir.chdir 'specs/test_files'
    File.open('file1', 'w+') { |f| f.puts "test file 1\n1234" }
    File.open('file2', 'w+') { |f| f.puts "test file 2\nasdf" }

    # Set up the testing repo
    @repo = Revert.new('.rev/')
    @repo.init_repo
    @repo.track_file 'file1'
    @repo.track_file 'file2'
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

  it "is properly tracking files" do
    @repo.tracked_files.index('file2').wont_be_nil
    @repo.tracked_files.index('file1').wont_be_nil
  end
end
