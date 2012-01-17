class User < ActiveRecord::Base
  has_many :roles
  has_many :projects, :through => :roles

  validates_presence_of :login
  validates_uniqueness_of :login

  def can_view?(project)
    viewer_role = RoleType.find_by_name("viewer")
    can_view = !!(self.roles.find_by_project_id_and_role_type_id(project.id, viewer_role.id) if viewer_role)
    can_view || can_build?(project)
  end

  def can_build?(project)
    builder_role = RoleType.find_by_name("builder")
    !!(self.roles.find_by_project_id_and_role_type_id(project.id, builder_role.id) if builder_role)
  end
end
