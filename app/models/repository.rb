class Repository
  def initialize(code_path, url, branch)
    @code_path = code_path
    @url = url
    @branch = branch
  end

  def revision
    Environment.system_call_output("cd #{@code_path} && git rev-parse --verify HEAD").strip
  end

  def checkout
    Environment.system("git clone --depth 1 #{@url} #{@code_path} --branch #{@branch}")
  end

  def update
    rev_before_update = revision
    Environment.system("cd #{@code_path} && git pull && git submodule init && git submodule update")
    rev_after_update = revision
    rev_before_update != rev_after_update
  end

  def change_list(old_sha, new_sha)
    return "" if old_sha.blank?
    Environment.system_call_output("cd #{@code_path} && git whatchanged #{old_sha}..#{new_sha} --pretty=oneline --name-status")
  end

  def versioned?(file_path)
    not Environment.system_call_output("cd #{@code_path} && git checkout #{file_path} 2>>/dev/null || echo 'not versioned'").include?('not versioned')
  end
end
