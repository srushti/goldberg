class RoleType < ActiveRecord::Base
  validates_uniqueness_of :name
  validates_presence_of :name
end
