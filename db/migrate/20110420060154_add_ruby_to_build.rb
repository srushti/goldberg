class AddRubyToBuild < ActiveRecord::Migration
  def self.up
    add_column :builds, :ruby, :string
  end

  def self.down
    remove_column :builds, :ruby
  end
end
