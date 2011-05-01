class AddEnvironmentVariablesToBuild < ActiveRecord::Migration
  def self.up
    add_column :builds, :environment_string, :string
  end

  def self.down
    remove_column :builds, :enviroment_string
  end
end
