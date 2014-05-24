require_relative 'spec_helper'

describe Reversion do
  before do
    # Create the file structure for the test
    FileUtils.mkdir_p 'specs/test_files'
    Dir.chdir 'specs/test_files'
    File.open('file1', 'w+') { |f| f.puts "test file 1\n1234" }
    File.open('file2', 'w+') { |f| f.puts "test file 2\nasdf" }

    # Set up the testing repo
    @repo = Reversion.new('.rev/')
    @repo.init_repo
    @repo.add_file 'file1'
    @repo.add_file 'file2'
  end

  after do
    Dir.chdir '../..'
    FileUtils.rm_rf 'specs/test_files/'
  end

  it "should be an instance of Revert" do
    @repo.must_be_instance_of Reversion
  end

  it "should create the proper directory" do
    File.directory?('.rev').must_equal true
  end

  it "is properly tracking files" do
    @repo.tracked_files.index('file2').wont_be_nil
    @repo.tracked_files.index('file1').wont_be_nil
  end

  it "should properly write out the manifest when committing" do
    @repo.commit
    manifest = File.read @repo.manifest
    manifest.must_match(/@tracked_files/)
    manifest.must_match(/file1/)
    manifest.must_match(/file2/)
  end
  
  it "should create an md5 hash when committing" do
    @repo.commit
    File.exists?('.rev/1.md5').must_equal true
  end

  it "will be a valid md5 hash" do
    @repo.commit
    Digest::MD5.hexdigest(File.read('.rev/1')).must_equal File.read('.rev/1.md5')
  end

  it "should correctly track files" do
    @repo.tracked?('file1').must_equal true    
    @repo.tracked?('file3').must_equal false
  end

  it "correctly tracks and stages files when you add them" do
    @repo.staged?('file1').must_equal true
    @repo.staged?('file3').must_equal false
  end

  it "should track commits correctly" do
    commit_id = @repo.commit
    File.exists?('.rev/1').must_equal true
    commit_id.must_equal 1
  end

  it "should be able to revert to a previous commit" do
    @repo.commit
    File.open 'file1', 'w+' do |f|
      f.puts "I'm changing it up!"
    end
    @repo.checkout 1
    File.read('file1').must_match(/1234/)
  end

  it "correctly checks for file corruption" do
    @repo.commit
    # Corrupt the commit
    File.open '.rev/1', 'w+' do |f|
      f.puts 'the beeeees! my eyes!'
    end
    @repo.checkout(1).wont_equal nil

    @repo.add_file('file2')
    @repo.commit
    @repo.checkout(2).must_equal nil
  end

  it "correctly lists modified files" do
    @repo.commit
    sleep 1 # Sleep at least one second so that the file mod time changes
    File.open('file1', 'w+') { |f| f.print "Modifed the file" }
    @repo.modified_files.must_equal ['file1']
  end

  it "correctly reports whether a commit is valid" do
    @repo.commit
    @repo.commit?(1).must_equal true
    @repo.commit?(1000).must_equal false
  end

  it "can remove tracked filed" do
    @repo.rm_file 'file1'
    @repo.tracked?('file1').must_equal false
    @repo.staged?('file1').must_equal false
  end

  it "should return a valid commit list" do
    @repo.commit
    @repo.commit
    @repo.commit_list.keys.length.must_equal 2
    @repo.commit_list.keys[0].must_equal ".rev/2"
    @repo.commit_list.keys[1].must_equal ".rev/1"
  end

  it "should track the commit message" do
    @repo.commit 'test commit'
    instance_eval File.read('.rev/1')
    @current_message.must_equal 'test commit'
  end

  it "creates an md5 has for the manifest" do
    @repo.commit 'test commit'
    File.exists?('.rev/manifest.md5').must_equal true
  end

  it "won't load a corrupt repo" do
    @repo.commit 'test commit'
    File.open(@repo.manifest, 'w+') { |f| f.puts "corruption!" }
    @repo.load_repo.wont_equal nil
  end
end
