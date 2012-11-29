class GemfileLock
  def initialize(file_name, code_path)
    @path = File.expand_path(file_name, code_path)
  end

  def requires_deletion?(gemfile_modification_time, versioned)
    File.exists?(@path) && versioned && gemfile_modification_time > modification_time
  end

  def modification_time
    File.mtime(@path)
  end

  def delete
    File.delete(@path)
  end
end
