require "fileutils"

class Project < ActiveRecord::Base
  has_many :builds, :dependent => :destroy
  after_destroy :remove
  delegate :number, :status, :log, :timestamp, :to => :latest_build, :prefix => true

  validates_presence_of :branch, :name, :url

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

  def cleanup_codebase
    #TODO Remove the Gemfile.lock only if Gemfile has been modified since last commit
    if File.exists?(File.expand_path('Gemfile.lock', self.code_path))
      File.delete(File.expand_path('Gemfile.lock', self.code_path)) unless self.repository.versioned?('Gemfile.lock')
    end
  end

  def run_build
    if self.repository.update || build_required?
      cleanup_codebase
      build_successful = self.builds.create!(:number => latest_build.number + 1, :previous_build_revision => latest_build.revision).run
      self.build_requested = false
      self.save
      Rails.logger.info "Build #{ build_successful ? "passed" : "failed!" }"
    end
  end

  def force_build
    Rails.logger.info "forcing build for #{self.name}"
    self.build_requested = true
    save
  end

  def command
    bundler_command = File.exists?(File.join(self.code_path, 'Gemfile')) ? "(bundle check || bundle install) && " : ""
    bundler_command << (custom_command || "rake")
  end

  def map_to_cctray_project_status
    case latest_build_status
      when 'passed' then
        'Success'
      when 'failed' then
        'Failure'
      else
        'Unknown'
    end
  end

  def repository
    @repository ||= Repository.new(code_path, url, branch)
  end

  def self.find_by_name(name)
    all.detect { |project| project.name == name }
  end
end
