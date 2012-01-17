class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.references :user, :project, :role_type
      t.timestamps
    end
  end
end
