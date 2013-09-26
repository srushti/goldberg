class AddBuildRequestedToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :build_requested, :boolean, default: false
  end

  def self.down
    remove_column :projects, :build_requested
  end
end
