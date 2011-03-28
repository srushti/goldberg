class CreateBuilds < ActiveRecord::Migration
  def self.up
    create_table :builds do |t|
      t.integer   :project_id
      t.integer   :number
      t.string    :revision
      t.boolean   :status
      t.string    :change_list
      t.timestamps
    end
  end

  def self.down
    drop_table :builds
  end
end
