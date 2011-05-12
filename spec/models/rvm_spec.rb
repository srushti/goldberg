require "spec_helper"

describe RVM do
  context "installed?" do
    before(:each) do
      Env.stub!(:[]).with('HOME').and_return('home')
      File.stub!(:exist?).with(File.join('home', '.rvm', 'scripts', 'rvm')).and_return(true)
    end

    it "writes the required rvmrc contents" do
      Environment.should_receive(:write_file).with('home/.rvmrc', "rvm_install_on_use_flag=1\nrvm_project_rvmrc=0\nrvm_gemset_create_on_use_flag=1\n")
      RVM.write_ci_rvmrc_contents
    end

    it "prepares a gemset with bundler" do
      Environment.should_receive(:system).with('source $HOME/.rvm/scripts/rvm $HOME/.rvm/scripts/rvm && rvm use project@global && (gem list | grep bundler) || gem install bundler')
      RVM.prepare_ruby('project')
    end

    it "marks the .rvmrc as trusted" do
      Environment.should_receive(:system).with('rvm rvmrc trust code_path')
      RVM.trust_rvmrc('code_path')
    end
  end
end
