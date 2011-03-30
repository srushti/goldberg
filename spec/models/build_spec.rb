require "spec_helper"

module Goldberg
  describe Build do
    it "should be able to fake the last version" do
      Build.nil.revision.should == ''
      Build.nil.should be_null
    end

    it "sorts correctly" do
      builds = [10, 9, 1, 500].map{|i| Factory(:build, :number => i)}
      builds.sort.map(&:number).map(&:to_i).should == [1, 9, 10, 500]
    end

    context "paths" do
      it "should know where to store the build artifacts on the file system" do
        project = Factory.build(:project, :name => "name")
        build = Factory.build(:build, :project => project, :number => 5)
        build.artifacts_path.should == File.join(project.path, "builds", "5")
      end
      
      [:change_list, :build_log].each do |artifact|
        it "should append build number to the project path to create a path for #{artifact}" do
          project = Factory.build(:project, :name => "name")
          build = Factory.build(:build, :project => project, :number => 5)
          build.send("#{artifact}_path").should == File.join(project.path, "builds", "5", artifact.to_s)
        end
      end
    end
    
    context "after create" do
      it "should create a directory for storing build artifacts" do
        project = Factory.build(:project, :name => 'ooga')
        build = Factory.build(:build, :project => project, :number => 5)
        FileUtils.should_receive(:mkdir_p).with(build.artifacts_path)
        build.save.should be_true
      end
    end
    
    # def build(task = :default)
    #       write_change_list
    #       Rails.logger.info "Building #{name}"
    #       Environment.system("source $HOME/.rvm/scripts/rvm && cd #{code_path} && BUNDLE_GEMFILE='' #{command} #{task.to_s} 2>&1") do |output, result|
    #         Environment.write_file(build_log_path, output)
    #         Rails.logger.info "Build status #{result}"
    #         builds.new(:project => self, :status => result, :number => latest_build_number + 1)
    #         File.delete(force_build_path) if File.exist?(force_build_path)
    #         copy_latest_build_to_its_own_folder
    #       end
    #     end
    #     
    context "changes" do
      
      it "should write a file with all the changes since the previous build" do
        pending
        project = Factory.build(:project, :name => 'ooga')
        build = Factory.build(:build, :project => project, :number => 5, :previous_build_revision => "random_sha")
        
        build.persist_change_list
      end
    end
  end
end
