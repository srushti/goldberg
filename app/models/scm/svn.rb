module Scm
  module Svn
    class << self
      def revision
        "svnversion ."
      end

      def checkout(url, code_path, branch)
        "svn co #{url} #{code_path}"
      end

      def update(branch)
        "svn revert -R . && svn update"
      end

      def change_list(old_rev, new_rev)
        "svn diff -r#{old_rev}:#{new_rev} | diffstat"
      end

      def version(file_path)
        "svn info #{file_path}"
      end

      def authors(versions)
        "svn log -r#{versions.first+':'+versions.last} | grep \"^[r\d]\" | awk '{print $3}'| uniq| tr \"\\n\" \" \""
      end
    end
  end
end
