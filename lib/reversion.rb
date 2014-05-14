require 'fileutils'


class Reversion
  attr_reader :tracked_files, :manifest, :last_commit

  def initialize(repo_dir)
    @repo_dir = repo_dir
    @manifest = File.join @repo_dir, 'manifest'

    if File.directory?(@repo_dir)
      # If repo already exists, load it
      load_repo
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
  end

  def load_repo
    # Load an already created repository
    instance_eval File.read(@manifest)
  end

  def write_manifest
    # Create the manifest
    File.open @manifest, 'w+' do |f|
      f.puts "@tracked_files = #{ @tracked_files.uniq.inspect }"
      f.puts "@last_commit = #{ @last_commit }"
      f.puts "@commit_times = #{ @commit_times }"
      f.puts "@staged_files = #{ @staged_files.uniq }"
    end
  end

  def commit
    @last_commit += 1 # Keep track of current commit number

    @staged_files.each do |s|
      @commit_times[s] = File.mtime s
    end

    # Write the actual commited files to the repo
    File.open File.join(@repo_dir, @last_commit.to_s), 'w+' do |f|
      commit_files = {}
      @staged_files.each { |s| commit_files[s] = File.read(s) }
      f.puts "@current_files = #{ commit_files.inspect }"
    end

    write_manifest
  end

  def checkout(commit_id)
    instance_eval File.read(File.join @repo_dir, commit_id.to_s)
    @current_files.each do |k,v|
      File.open k, 'w+' do |f|
        f.puts v
      end
    end
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

  def modified_files
    @tracked_files.select { |f| File.mtime(f) > @commit_times[f] }
  end

  def commit?(commit_id)
    File.exists? File.join(@repo_dir, commit_id.to_s)
  end
end
