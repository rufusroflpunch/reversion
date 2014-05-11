require 'fileutils'


class Revert
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
      f.puts "@tracked_files = #{ @tracked_files.inspect }"
      f.puts "@last_commit = #{ @last_commit }"
    end
  end

  def commit
    @last_commit += 1 # Keep track of current commit number

    # Write the actual commited files to the repo
    File.open File.join(@repo_dir, @last_commit.to_s), 'w+' do |f|
      f.print '@current_files = {'
      @tracked_files.each do |t|
        f.print "#{ t.inspect } => #{ File.read(t).inspect }"
        f.print ',' if t != @tracked_files.last
      end
      f.print '}'
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

  def modified_files

  end
end
