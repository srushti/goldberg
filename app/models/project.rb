require "fileutils"

class Project < ActiveRecord::Base
  has_many :builds
  after_destroy :remove

  def self.add(options)
    Project.new(:name => options[:name], :custom_command => options[:command], :url => options[:url]).tap do |project|
      project.checkout(options[:url])
    end.save!
  end

  def remove
    FileUtils.rm_rf(path)
  end

  def checkout(url)
    FileUtils.mkdir_p(File.join(Paths.projects, name))
    if !Environment.system("git clone #{url} #{code_path}")
      remove
    end
  rescue
    remove
    raise
  end

  def build_anyway?
    !File.exist?(build_status_path) || !File.exist?("#{build_log_path}") || File.exist?(force_build_path)
  end

  def update
    Rails.logger.info "Checking #{name}"
    if !Environment.system_call_output("cd #{code_path} ; git pull").include?('Already up-to-date.') || build_anyway?
      if block_given?
        yield self
      end
    end
  rescue Exception => e
    Rails.logger.error e
  end

  ['build_status', 'force_build', 'build_log', 'change_list', 'code', 'build_number', 'build_version', 'builds', 'change_list', 'custom_command'].each do |relative_path|
    define_method "#{relative_path}_path".to_sym do
      path(relative_path)
    end
  end

  def latest_build_number
    (builds.sort.last || Build.null).number
  end

  def path(extra = '')
    File.join(Paths.projects, name, extra)
  end

  def latest_build
    builds.first || Build.new("")
  end

  def copy_latest_build_to_its_own_folder
    new_build_number = (latest_build_number + 1).to_s
    FileUtils.mkdir_p(File.join(builds_path, new_build_number), :verbose => true)
    FileUtils.cp(File.join(path('build_log')), File.join(builds_path, new_build_number), :verbose => true)
  end

  def build(task = :default)
    write_change_list
    Rails.logger.info "Building #{name}"
    Environment.system("source $HOME/.rvm/scripts/rvm && cd #{code_path} && BUNDLE_GEMFILE='' #{command} #{task.to_s} 2>&1") do |output, result|
      Environment.write_file(build_log_path, output)
      Rails.logger.info "Build status #{result}"
      builds.new(:project => self, :status => result, :number => latest_build_number + 1)
      File.delete(force_build_path) if File.exist?(force_build_path)
      copy_latest_build_to_its_own_folder
    end
  end

  def status
    latest_build.status
  end

  def last_built_at
    latest_build.timestamp
  end

  def id
    name.hash.abs
  end

  def build_log
    File.exist?(build_log_path) ? Environment.read_file(build_log_path) : ''
  end

  def force_build
    Environment.write_file(force_build_path, '')
    update
  end

  def write_change_list
    if latest_build.revision.nil?
      return
    end
    latest_build_version = latest_build.revision
    new_build_revision = build_revision
    latest_build_revision.gsub!(/\n/,'')
    new_build_revision.gsub!(/\n/,'')
    changes = Environment.system_call_output("cd #{code_path} ; git diff --name-status #{latest_build_revision} #{new_build_revision}")
    Environment.write_file(change_list_path, changes)
  end

  def build_version
    Environment.read_file(build_version_path)
  end

  def command
    custom_command || "rake"
  end

  def map_to_cctray_project_status
    case status
    when 'passed' then 'Success'
    when 'failed' then 'Failure'
    else 'Unknown'
    end
  end

  def self.find_by_name(name)
    all.detect{|project| project.name == name}
  end
end
