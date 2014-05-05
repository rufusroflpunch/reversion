require 'diff-lcs'
require 'fileutils'


class Revert
  attr_reader :tracked_files

  def initialize(repo_dir)
    @repo_dir = repo_dir

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
    FileUtils.touch File.join(@repo_dir, 'manifest')
  end

  def load_repo
    # Load an already created repository
    instance_eval File.read(File.join @repo_dir, 'manifest')
  end

  def commit

  end

  def checkout(commit_id)

  end

  def track_file(fname)
    @tracked_files << fname    
  end

  def is_tracked(fname)

  end
end
