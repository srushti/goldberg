class AddNextBuildAtToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :next_build_at, :timestamp
  end

  def self.down
    remove_column :projects, :next_build_at
  end
end
