require 'fileutils'
require 'date'
require 'digest/md5'


class Reversion
  attr_reader :tracked_files, :manifest, :last_commit

  def initialize(repo_dir)
    @repo_dir = repo_dir
    @manifest = File.join @repo_dir, 'manifest'

    if File.directory?(@repo_dir)
      # If repo already exists, load it
      load = load_repo
      
      if load != nil
        raise load
      end
    else
      # Load sane defaults
      @tracked_files = []
      @last_commit = 0
      @current_files = {}
      @commit_times = {} # Keeps track of the last file commit times
      @staged_files = []
    end
  end

  def init_repo
    # Actually create the source code respository
    FileUtils.mkdir_p @repo_dir
    FileUtils.touch @manifest

    write_manifest
  end

  def load_repo
    manifest = File.read @manifest
    manifest_hash = File.read "#{ @manifest }.md5"

    # Is the manifest intact?
    if manifest_hash != Digest::MD5.hexdigest(manifest)
      return "Manifest is corrupt. You may need to reinitialize the repo."
    end

    # Load an already created repository
    instance_eval manifest

    return nil    # No error!
  end

  def write_manifest
    # Create the manifest
    manifest = "@tracked_files = #{ @tracked_files.uniq.inspect }\n"
    manifest += "@last_commit = #{ @last_commit }\n"
    manifest += "@commit_times = #{ @commit_times.inspect }\n"
    manifest += "@staged_files = #{ @staged_files.uniq }\n"

    # Write the manifest
    File.open @manifest, 'w+' do |f|
      f.print manifest
    end

    # Write the hash
    File.open "#{ @manifest }.md5", 'w+' do |f|
      f.print Digest::MD5.hexdigest(manifest)
    end
  end

  def commit(message = '')
    @last_commit += 1 # Keep track of current commit number

    @staged_files.each do |s|
      @commit_times[s] = File.mtime(s).inspect
    end

    # Build the commit string and md5 hash.
    commit_files = {}
    @staged_files.each { |s| commit_files[s] = File.read(s) }
    commit_str = "@current_files = #{ commit_files.inspect }\n"
    commit_str += "@current_message = #{ message.inspect }\n"
    commit_hash = Digest::MD5.hexdigest(commit_str)
    
    # Write the actual commited files to the repo
    File.open File.join(@repo_dir, @last_commit.to_s), 'w+' do |f|
      f.print commit_str
    end

    File.open File.join(@repo_dir, "#{ @last_commit.to_s }.md5"), 'w+' do |f|
      f.print commit_hash
    end

    @staged_files = [] # Clear the stage after committing
    write_manifest

    return @last_commit # Return the commit number
  end

  def checkout(commit_id)
    commit_file = File.read(File.join @repo_dir, commit_id.to_s)
    commit_hash = File.read(File.join @repo_dir, "#{ commit_id }.md5")

    # Check the file integrity.
    if Digest::MD5.hexdigest(commit_file) != commit_hash
      return "Commit #{ commit_id } is corrupted."
    end

    instance_eval commit_file
    @current_files.each do |k,v|
      File.open k, 'w+' do |f|
        f.puts v
      end
    end
    nil   # No error. Yay!
  end

  def track_file(fname)
    @tracked_files << fname    
    write_manifest
  end

  def tracked?(fname)
    @tracked_files.index(fname) != nil
  end

  def stage_file(fname)
    @staged_files << fname
    write_manifest
  end

  def staged?(fname)
    @staged_files.index(fname) != nil
  end

  def add_file(fname)
    stage_file fname
    track_file fname
  end

  def rm_file(fname)
    @tracked_files.delete fname
    @staged_files.delete fname

    write_manifest
  end

  def modified_files
    @tracked_files.select { |f| @commit_times[f] && 
          File.mtime(f).to_s > @commit_times[f] }
  end

  def commit?(commit_id)
    File.exists? File.join(@repo_dir, commit_id.to_s)
  end

  def commit_list
    file_list = Dir.glob(File.join(@repo_dir, "[1-9]*")).sort.reverse
    file_list.delete_if {|f| f =~ /md5/ } # Make sure no hashes are included.
    commit_list = {}
    file_list.each do |f|
      instance_eval File.read(f)
      commit_list[f] = @current_files.keys
      commit_list[f].insert(0, @current_message) # The commit message is the first
                                                 # element of the array.
    end
    return commit_list
  end
end
