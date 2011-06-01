class RemoveCustomCommandFromProject < ActiveRecord::Migration
  def self.up
    remove_column :projects, :custom_command
  end

  def self.down
    add_column :projects, :custom_command
  end
end
