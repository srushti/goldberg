class Repository
  def initialize(code_path, url, branch)
    @code_path = code_path
    @url = url
    @branch = branch
    @provider = ScmProvider.provider(url)
  end

  def revision
    Environment.system_call_output("cd #{@code_path} && #{@provider.revision}").strip
  end

  def checkout
    Environment.system(@provider.checkout(@url,@code_path,@branch))
  end

  def update
    rev_before_update = revision
    Environment.system("cd #{@code_path} && #{@provider.update}")
    rev_after_update = revision
    rev_before_update != rev_after_update
  end

  def change_list(old_sha, new_sha)
    return "" if old_sha.blank?
    Environment.system_call_output("cd #{@code_path} && #{@provider.change_list(old_sha,new_sha)}")
  end

  def versioned?(file_path)
    not Environment.system_call_output("cd #{@code_path} && #{@provider.version(file_path)} 2>>/dev/null || echo 'not versioned'").include?('not versioned')
  end
end
