class AddEnvToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :project_environment_string, :string

    Project.reset_column_information
    Project.all.each do |project|
      project.update_attribute(:project_environment_string, '')
    end
  end

  def self.down
    remove_column :project_environment_string
  end
end