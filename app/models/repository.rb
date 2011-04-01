class Repository
  def initialize(code_path, url)  
    @code_path = code_path
    @url = url
  end
  
  def revision
    Environment.system_call_output("cd #{@code_path} && git rev-parse --verify HEAD")
  end
  
  def checkout
    Environment.system("git clone --depth 1 #{@url} #{@code_path}")
  end
  
  def update
    rev_before_update = revision
    Environment.system("cd #{@code_path} && git pull")
    rev_after_update = revision
    rev_before_update != rev_after_update
  end
  
  def change_list(old_sha, new_sha)
    return "" if old_sha.blank?
    Environment.system_call_output("cd #{@code_path} && git whatchanged #{old_sha.strip}..#{new_sha.strip} --pretty=oneline --name-status")
  end
end
