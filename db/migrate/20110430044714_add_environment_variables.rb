class AddEnvironmentVariables < ActiveRecord::Migration
  def self.up
    add_column :projects, :environment_variables, :string
  end

  def self.down
    remove_column :projects, :environment_variables
  end
end
