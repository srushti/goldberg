class ScmProvider
  class Git
    class << self
      def revision
        "git rev-parse --verify HEAD"
      end
      def checkout(url,code_path,branch)
        "git clone --depth 1 #{url} #{code_path} --branch #{branch}"
      end
      def update
        "git pull && git submodule init && git submodule update"
      end
      def change_list(old_rev,new_rev)
        "git whatchanged #{old_rev}..#{new_rev} --pretty=oneline --name-status"
      end
      def version(file_path)
        "git checkout #{file_path}"
      end
    end
  end


  class Svn
    class << self
      def revision
        "svnversion ."
      end
      def checkout(url,code_path,branch)
        "svn co #{url} #{@ode_path}"
      end
      def update
        "svn update"
      end
      def change_list(old_rev,new_rev)
        "svn diff -r#{old_rev}:#{new_rev} | diffstat"
      end
      def version(file_path)
        "svn info #{file_path}"
      end
    end
  end


  def self.provider(url)
    url.starts_with?("git")? ScmProvider::Git : ScmProvider::Svn
  end
end
