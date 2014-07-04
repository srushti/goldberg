class AddProjectSpecificEnvVariables < ActiveRecord::Migration
  def change
    add_column :projects, :env_string, :string, default: ''
  end
end

