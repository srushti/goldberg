class ProjectFile
  def initialize(name, path)
    @path ||= File.expand_path(name, path)
  end

  def exists?
    File.exists?(@path)
  end

  def versioned?(repository)
    repository.versioned?(@path)
  end

  def newer_than?(other_project_file)
    mtime > other_project_file.mtime
  end

  def mtime
    File.mtime(@path)
  end

  def delete
    File.delete(@path)
  end
end
