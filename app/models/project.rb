require "fileutils"

class Project < ActiveRecord::Base
  has_many :builds, :dependent => :destroy
  after_destroy :remove
  delegate :number, :status, :build_log, :timestamp, :to => :latest_build, :prefix => true
  delegate :timestamp, :status, :to => :last_complete_build, :prefix => true

  validates_presence_of :branch, :name, :url

  delegate :frequency, :ruby, :environment_string, :timeout, :to => :config

  def self.add(options)
    Project.new(:name => options[:name], :custom_command => options[:command], :url => options[:url], :branch => options[:branch]).tap do |project|
      project.checkout
      project.save!
    end
  end

  def remove
    FileUtils.rm_rf(path)
  end

  def checkout
    if !self.repository.checkout
      remove
    end
  rescue
    remove
    raise
  end

  def build_required?
    latest_build.nil_build? || self.build_requested?
  end

  def code_path
    path("code")
  end

  def path(extra = '')
    File.join(Paths.projects, name, extra)
  end

  def latest_build
    builds.first || Build.nil
  end

  def prepare_for_build
    gemfile = File.expand_path('Gemfile', self.code_path)
    gemfilelock = File.expand_path('Gemfile.lock', self.code_path)

    if File.exists?(gemfilelock) && !repository.versioned?('Gemfile.lock') && (File.mtime(gemfile) > File.mtime(gemfilelock) || ruby != latest_build.ruby)
      Rails.logger.info("removing Gemfile.lock as it's not versioned")
      File.delete(gemfilelock)
    end
  end

  def run_build
    clean_up_older_builds
    if self.repository.update || build_required?
      previous_build_status = last_complete_build_status
      prepare_for_build
      new_build = self.builds.create!(:number => latest_build.number + 1, :previous_build_revision => latest_build.revision, :ruby => ruby,
                                      :environment_string => environment_string).tap(&:run)
      self.build_requested = false
      Rails.logger.info "Build #{ new_build.status }"
      after_build_runner.execute(latest_build, self, previous_build_status)
    end
    self.next_build_at = Time.now + frequency.seconds
    self.save
  end

  def clean_up_older_builds
    builds.where(:status => 'building').each { |b| b.update_attributes(:status => 'cancelled') }
  end

  def after_build_runner
    BuildPostProcessor.new(config)
  end

  def force_build
    Rails.logger.info "forcing build for #{self.name}"
    self.build_requested = true
    save
  end

  def build_command
    bundler_command = File.exists?(File.join(self.code_path, 'Gemfile')) ? "(#{Bundle.check_and_install}) && " : ""
    bundler_command << (custom_command || "rake #{config.rake_task}")
  end

  def map_to_cctray_project_status
    {'passed' => 'Success', 'timeout' => 'Failure', 'failed' => 'Failure'}[last_complete_build.status] || 'Unknown'
  end

  def last_complete_build
    builds.detect { |build| !['building', 'cancelled'].include?(build.status) } || Build.nil
  end

  def repository
    @repository ||= Repository.new(code_path, url, branch)
  end

  def self.find_by_name(name)
    all.detect { |project| project.name == name }
  end

  def config
    if File.exists?(File.expand_path('goldberg_config.rb', self.code_path))
      config_code = File.read(File.expand_path('goldberg_config.rb', self.code_path))
      eval(config_code)
    else
      ProjectConfig.new
    end
  end

  def self.configure
    config = ProjectConfig.new
    yield config
    config
  end

  def self.projects_to_build
    Project.where("build_requested = 't' or next_build_at is null or next_build_at <= :next_build_at", :next_build_at => Time.now)
  end

  def activity
    {'passed' => 'Sleeping', 'timeout' => 'Sleeping', 'failed' => 'Sleeping', 'building' => 'Building'}[latest_build_status] || 'Unknown'
  end
end
