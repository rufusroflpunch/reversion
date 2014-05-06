require 'diff-lcs'
require 'fileutils'


class Revert
  attr_reader :tracked_files, :manifest

  def initialize(repo_dir)
    @repo_dir = repo_dir
    @manifest = File.join @repo_dir, 'manifest'

    if File.directory?(@repo_dir)
      # If repo already exists, load it
      load_repo
    else
      # Load sane defaults
      @tracked_files = []
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

  def commit
    # Write the new file list out to the manifest
    File.open @manifest, 'w+' do |f|
      f.puts "@tracked_files = #{ @tracked_files.inspect }"
    end
  end

  def checkout(commit_id)

  end

  def track_file(fname)
    @tracked_files << fname    
  end

  def tracked?(fname)
    @tracked_files.index(fname) != nil ? true : false
  end
end
