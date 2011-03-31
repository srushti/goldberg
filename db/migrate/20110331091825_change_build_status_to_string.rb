class ChangeBuildStatusToString < ActiveRecord::Migration
  def self.up
    remove_column :builds, :status
    add_column :builds, :status, :string
  end

  def self.down
    remove_column :builds, :status
    add_column :builds, :status, :boolean
  end
end