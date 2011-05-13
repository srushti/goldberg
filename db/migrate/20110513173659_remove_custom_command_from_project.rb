class RemoveCustomCommandFromProject < ActiveRecord::Migration
  def self.up
    remove_column :projects, :custom_commaand
  end

  def self.down
    add_column :projects, :custom_commaand, :string
  end
end
