require "ostruct"

class Build < ActiveRecord::Base
  include Comparable
  
  attr_accessor :previous_build_revision
  after_create :create_artifacts_dir
  
  belongs_to :project

  def self.nil
    OpenStruct.new(:number => 0, :status => 'never run', :revision => '', :null? => true, :timestamp => nil)
  end

  def log
    Environment.read_file(build_log_path)
  end

  def change_list
    File.exist?(change_list_path) ? Environment.read_file(change_list_path) : nil
  end

  def timestamp
    File.ctime(build_status_path)
  end

  def artifacts_path
    File.join(project.path, "builds", number.to_s)
  end
  %w(change_list build_log).each do |file_name|
    define_method "#{file_name}_path".to_sym do
      File.join(artifacts_path, file_name)
    end
  end

  def status
    if File.exist?(build_status_path)
      Environment.read_file(build_status_path).strip == 'true' ? 'passed' : 'failed'
    else
      nil
    end
  end

  def version
    File.exist?(build_version_path) ? Environment.read_file(build_version_path) : nil
  end

  def <=>(other)
    number.to_i <=> other.number.to_i
  end
  
  def run
    true
  end
  
  def create_artifacts_dir
    FileUtils.mkdir_p(artifacts_path)
  end
end
