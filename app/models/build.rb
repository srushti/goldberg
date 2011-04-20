require "ostruct"
require 'fileutils'

class Build < ActiveRecord::Base
  include Comparable

  attr_accessor :previous_build_revision
  after_create :create_artefacts_dir
  before_create :update_revision

  belongs_to :project

  default_scope order('number DESC')

  def self.nil
    OpenStruct.new(:number => 0, :status => 'not available', :revision => '', :nil_build? => true, :timestamp => nil, :log => '')
  end

  def log
    Environment.file_exist?(build_log_path) ? Environment.read_file(build_log_path) : ''
  end

  def change_list
    Environment.file_exist?(change_list_path) ? Environment.read_file(change_list_path) : nil
  end

  def timestamp
    self.created_at
  end

  def artefacts_path
    File.join(project.path, "builds", number.to_s)
  end

  %w(change_list build_log).each do |file_name|
    define_method "#{file_name}_path".to_sym do
      File.join(artefacts_path, file_name)
    end
  end

  def <=>(other)
    number.to_i <=> other.number.to_i
  end

  def run
    before_build
    Bundler.with_clean_env do
      ENV['BUNDLE_GEMFILE'] = nil
      ENV['RAILS_ENV'] = project.rails_env
      ENV["RUBYOPT"] = nil # having RUBYOPT was causing problems while doing bundle install resulting in gems not being installed - aakash
      RVM.prepare_ruby(ruby)
      go_to_project_path = "cd #{project.code_path}"
      build_command = "#{project.build_command}"
      output_redirects = "1>>#{build_log_path} 2>>#{build_log_path}"
      Environment.system("(#{RVM.use_script(ruby, project.name)} ; #{go_to_project_path};  #{build_command}) #{output_redirects}").tap do |success|
        if success
          self.status = "passed"
        else
          self.status = "failed"
        end
        save
      end
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

  def create_artefacts_dir
    FileUtils.mkdir_p(artefacts_path)
  end

  def update_revision
    self.revision = project.repository.revision if self.revision.blank?
  end

  def nil_build?
    false
  end
end
