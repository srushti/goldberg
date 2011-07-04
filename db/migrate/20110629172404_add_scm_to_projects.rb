class AddScmToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :scm, :string

    Project.reset_column_information
    Project.all.each do |project|
      project.update_attribute(:scm, 'git')
    end
  end

  def self.down
    remove_column :scm, :branch
  end
end
