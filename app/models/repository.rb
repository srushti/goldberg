class Repository
  def initialize(code_path, url, branch,scm)
    @code_path = code_path
    @url = url
    @branch = branch
    @provider = Scm.provider(scm)
  end

  def revision
    Command.new("cd #{@code_path} && #{@provider.revision}").execute_with_output.strip
  end

  def checkout
    Command.new(@provider.checkout(@url, @code_path, @branch)).execute
  end

  def update
    rev_before_update = revision
    Command.new("cd #{@code_path} && #{@provider.update}").execute
    rev_after_update = revision
    rev_before_update != rev_after_update
  end

  def change_list(old_sha, new_sha)
    return "" if old_sha.blank?
    Command.new("cd #{@code_path} && #{@provider.change_list(old_sha, new_sha)}").execute_with_output
  end
  def author(version)
    Command.new("cd #{@code_path} && #{@provider.author(version)}").execute_with_output.strip
  end

  def versioned?(file_path)
    not Command.new("cd #{@code_path} && #{@provider.version(file_path)} 2>>/dev/null || echo 'not versioned'").execute_with_output.include?('not versioned')
  end
end
