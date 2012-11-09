require "ostruct"
require 'fileutils'

class Build < ActiveRecord::Base
  include Comparable

  attr_accessor :previous_build_revision
  after_create :create_dir
  before_create :update_revision

  belongs_to :project

  default_scope order('number DESC')

  def self.per_page
    50
  end

  paginates_per per_page

  def self.null
    OpenStruct.new(:number => 0, :status => 'not available', :revision => '', :nil_build? => true, :timestamp => nil, :build_log => '', :artefacts => [])
  end

  def timestamp
    self.created_at
  end

  def path
    File.join(project.path, "builds", number.to_s)
  end

  %w(change_list build_log).each do |file_name|
    define_method "#{file_name}_path".to_sym do
      File.join(path, file_name)
    end

    define_method "#{file_name}" do
      file_path = send("#{file_name}_path")
      Environment.file_exist?(file_path) ? Environment.read_file(file_path) : ''
    end
  end

  def artefacts_path
    File.join(path, "artefacts")
  end

  def <=>(other)
    number.to_i <=> other.number.to_i
  end

  def run
    before_build
    Bundler.with_clean_env do
      build_command = "script/goldberg-build '#{project.name}' '#{ruby}' '#{project.code_path}' '#{build_log_path}' '#{artefacts_path}' '#{project.nice}' '#{environment_string}' '#{project.bundler_options}' #{project.build_command}"
      execute_async(build_command)
    end
  end

  def execute_async(command)
    command = Command.new(command)
    command.fork
    while (!exceeded_timeout?(command.start_time) && command.running? && !reload.cancelled?)
      sleep(10)
    end
    if cancelled?
      command.stop_tree
      Goldberg.logger.info "Cancelled pid #{command.pid}, build no #{number} of #{project.name}, #{command.stopped?}"
    elsif exceeded_timeout?(command.start_time)
      command.stop_tree
      Goldberg.logger.error "Timeout (#{project.timeout})- killing #{command.pid}:#{command.cmd}"
      update_attributes(status: 'timeout')
    else
      update_attributes(status: command.success? ? 'passed' : 'failed')
    end
  end

  def exceeded_timeout?(start_time)
    project.timeout != Project::Configuration::NO_TIMEOUT && DateTime.now > start_time + project.timeout
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

  def create_dir
    FileUtils.mkdir_p(path)
  end

  def update_revision
    self.revision = project.repository.revision if self.revision.blank?
  end

  def nil_build?
    false
  end

  def artefacts
    if Environment.exist?(artefacts_path)
      Dir.entries(artefacts_path) - ['.', '..']
    else
      []
    end
  end

  def cancel
    update_attributes(:status => 'cancelled')
  end

  def duration
    if building?
      Time.now - created_at
    else
      updated_at - created_at
    end
  end

  ['timeout', 'cancelled', 'passed', 'failed', 'building', ].each do |status|
    define_method("#{status}?") { self.status == status }
  end
end
