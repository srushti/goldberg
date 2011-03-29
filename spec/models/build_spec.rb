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
    context "run" do
      
    end
  end
end
