require "ostruct"

class Build < ActiveRecord::Base
  include Comparable

  belongs_to :project

  def self.null
    OpenStruct.new(:number => 0, :status => 'never run', :revision => 'HEAD', :null? => true, :timestamp => nil)
  end

  def self.create(path)
    Build.new(:path => path)
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

  %w(build_status change_list build_log build_version).each do |file_name|
    define_method "#{file_name}_path".to_sym do
      File.join(@path, file_name)
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

  protected
  def path
    File.join
    @path
  end
end
