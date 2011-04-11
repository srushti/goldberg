class AddBranchToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :branch, :string

    Project.reset_column_information
    Project.all.each do |project|
      project.update_attribute(:branch, 'master')
    end
  end

  def self.down
    remove_column :projects, :branch
  end
end
