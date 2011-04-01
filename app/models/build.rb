require "ostruct"

class Build < ActiveRecord::Base
  include Comparable
  
  attr_accessor :previous_build_revision
  after_create :create_artifacts_dir
  before_create :update_revision
  
  belongs_to :project

  def self.nil
    OpenStruct.new(:number => 0, :status => 'never run', :revision => '', :nil_build? => true, :timestamp => nil)
  end

  def log
    Environment.read_file(build_log_path)
  end

  def change_list
    File.exist?(change_list_path) ? Environment.read_file(change_list_path) : nil
  end

  def timestamp
    self.created_at
  end

  def artifacts_path
    File.join(project.path, "builds", number.to_s)
  end
  
  %w(change_list build_log).each do |file_name|
    define_method "#{file_name}_path".to_sym do
      File.join(artifacts_path, file_name)
    end
  end

  def <=>(other)
    number.to_i <=> other.number.to_i
  end
  
  def run
    before_build
    require_rvm = "source $HOME/.rvm/scripts/rvm"
    go_to_project_path = "cd #{project.code_path}"
    build_command = "BUNDLE_GEMFILE='' #{project.command}"
    output_redirects = "1>>#{build_log_path} 2>>#{build_log_path}"
    Environment.system("#{require_rvm} && #{go_to_project_path}  && #{build_command} #{output_redirects}").tap do |success|
      if success
        self.status = "passed"
      else
        self.status = "failed"
      end
      save
    end
  end
  
  def before_build
    self.status = "building"
    save
    persist_change_list
  end
  
  def persist_change_list
    change_list = project.repository.change_list(previous_build_revision, revision)
    File.open(change_list_path, "w+") do |file|
      file.write(change_list)
    end
  end
  
  def create_artifacts_dir
    FileUtils.mkdir_p(artifacts_path)
  end
  
  def update_revision
    self.revision = project.repository.revision if self.revision.blank?
  end
  
  def nil_build?
    false
  end
end
