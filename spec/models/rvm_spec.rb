require "spec_helper"

describe RVM do
  it "writes the required rvmrc contents" do
    Env.stub!(:[]).with('HOME').and_return('home')
    Environment.should_receive(:write_file).with('home/.rvmrc', "rvm_install_on_use_flag=1\nrvm_project_rvmrc=0\nrvm_gemset_create_on_use_flag=1\n")
    RVM.write_ci_rvmrc_contents
  end
end
