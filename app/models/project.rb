require 'fileutils'

class Project < ActiveRecord::Base
  has_many :builds, dependent: :destroy
  after_destroy :remove
  delegate :number, :status, :build_log, :timestamp, to: :latest_build, prefix: true
  delegate :timestamp, :status, :number, to: :last_complete_build, prefix: true
  cattr_accessor :temp_config

  validates_presence_of :branch, :name, :url
  validates_uniqueness_of :name

  delegate :frequency, :ruby, :environment_string, :timeout, :nice, :group, :bundler_options, to: :config

  def self.projects_to_build
    where("build_requested = ? or next_build_at is null or next_build_at <= ?", true, Environment.now)
  end

  def self.add(options)
    project = Project.new(name: options[:name], url: options[:url], branch: options[:branch], scm: options[:scm], env_string: project_env(options[:env]).to_s)
    return if !project.valid?
    if project.checkout
      project.save!
      project
    end
  end

  def self.project_env(env_list)
    env_vars = {}
    unless env_list.blank?
      env_list.each do |env_var|
        tmp = env_var.split('=')
        env_vars.store(tmp[0], tmp[1] || '')
      end
    end
    env_vars
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
    gemfile = ProjectFile.new('Gemfile', code_path)
    gemfile_lock = ProjectFile.new('Gemfile.lock', code_path)

    if gemfile_lock.exists? && (!gemfile_lock.versioned?(repository) && (gemfile.newer_than?(gemfile_lock) || ruby != latest_build.ruby))
      Goldberg.logger.info("removing Gemfile.lock as it's not versioned")
      gemfile_lock.delete
    end
  end

  def run_build
    clean_up_older_builds
    if self.repository.update || build_required?
      previous_build_status = last_complete_build_status
      prepare_for_build
      current_build = new_build.tap(&:run)
      Goldberg.logger.info "Build #{ current_build.status }"
      after_build_runner.execute(current_build, previous_build_status)
    end
    update_attributes(next_build_at: frequency.seconds.from_now, build_requested: false)
  end

  def new_build
    self.builds.create!(number: latest_build.number + 1, previous_build_revision: latest_build.revision, ruby: ruby, environment_string: environment_string)
  end

  def clean_up_older_builds
    builds.where(status: 'building').each { |b| b.update_attributes(status: 'cancelled') }
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
    config_custom_env(self.class.temp_config)
    self.class.temp_config
  end

  def config_custom_env(configuration)
    if(self.env_string.present?)
      configuration.environment_variables=eval(self.env_string)
    end
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
