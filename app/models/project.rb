require "fileutils"

class Project < ActiveRecord::Base
  has_many :builds, :dependent => :destroy
  after_destroy :remove
  delegate :number, :status, :build_log, :timestamp, :to => :latest_build, :prefix => true
  delegate :timestamp, :status, :number, :to => :last_complete_build, :prefix => true
  cattr_accessor :temp_config

  validates_presence_of :branch, :name, :url
  validates_uniqueness_of :name

  delegate :frequency, :ruby, :environment_string, :timeout, :nice, :group, :bundler_options, :to => :config

  def self.projects_to_build
    where("build_requested = ? or next_build_at is null or next_build_at <= ?", true, Environment.now)
  end

  def self.add(options)
    project = Project.new(:name => options[:name], :url => options[:url], :branch => options[:branch], :scm => options[:scm])
    return if !project.valid?
    if project.checkout
      project.save!
      project
    end
  end

  def remove
    FileUtils.rm_rf(path)
  end

  def checkout
    self.repository.checkout.tap{|result| remove unless result}
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
    builds.first || Build.null
  end

  def prepare_for_build
    gemfile = File.expand_path('Gemfile', self.code_path)
    gemfilelock = File.expand_path('Gemfile.lock', self.code_path)

    if File.exists?(gemfilelock) && !repository.versioned?('Gemfile.lock') && (File.mtime(gemfile) > File.mtime(gemfilelock) || ruby != latest_build.ruby)
      Goldberg.logger.info("removing Gemfile.lock as it's not versioned")
      File.delete(gemfilelock)
    end
  end

  def run_build
    clean_up_older_builds
    if self.repository.update || build_required?
      update_attributes(build_requested: false)
      previous_build_status = last_complete_build_status
      prepare_for_build
      new_build = new_build(:number => latest_build.number + 1, :previous_build_revision => latest_build.revision, :ruby => ruby, :environment_string => environment_string).tap(&:run)
      Goldberg.logger.info "Build #{ new_build.status }"
      after_build_runner.execute(new_build, previous_build_status)
    end
    self.next_build_at = Time.now + frequency.seconds
    self.save
  end

  def new_build(params)
    self.builds.create!(params)
  end

  def clean_up_older_builds
    builds.where(:status => 'building').each { |b| b.update_attributes(:status => 'cancelled') }
  end

  def after_build_runner
    BuildPostProcessor.new(config)
  end

  def force_build
    Goldberg.logger.info "forcing build for #{self.name}"
    update_attributes(build_requested: true)
  end

  def build_command
    build_command = config.command || "#{config.use_bundle_exec ? 'bundle exec ' : ''}rake #{config.rake_task}"
  end

  def map_to_cctray_project_status
    {'passed' => 'Success', 'timeout' => 'Failure', 'failed' => 'Failure'}[last_complete_build.status] || 'Unknown'
  end

  def last_complete_build
    builds.detect { |build| !['building', 'cancelled'].include?(build.status) } || Build.null
  end

  def culprits_for_failure
    culprit_revision_range.empty? ? '' : repository.authors(culprit_revision_range.collect(&:revision))
  end

  def culprit_revision_range
    return [] if last_complete_build.status == 'passed'
    result = []
    builds.each do |build|
      break if build.status == 'passed'
      result << build
    end
    result
  end

  def repository
    @repository ||= Repository.new(code_path, url, branch, scm)
  end

  def self.find_by_name(name)
    all.detect { |project| project.name == name }
  end

  def config
    self.class.temp_config = Configuration.new
    [self.code_path, self.path].each do |path|
      if File.exists?(File.expand_path('goldberg_config.rb', path))
        config_code = Environment.read_file(File.expand_path('goldberg_config.rb', path))
        eval(config_code)
      end
    end
    self.class.temp_config
  end

  def self.configure
    (Project.temp_config ||= Configuration.new).tap{|config| yield config}
  end

  def build_queued?
    build_requested? && latest_build_status != 'building'
  end

  def activity
    {'passed' => 'Sleeping', 'timeout' => 'Sleeping', 'failed' => 'Sleeping', 'building' => 'Building'}[latest_build_status] || 'Unknown'
  end

  def github_url
    if url.include?('//github.com')
      url.gsub(/^git:\/\//, 'http://').gsub(/\.git$/, '')
    elsif url.include?('git@github.com')
      url.gsub(/:/, '/').gsub(/^git@/, 'http://').gsub(/\.git$/, '')
    end
  end

  def building?
    latest_build && latest_build.building?
  end
end
