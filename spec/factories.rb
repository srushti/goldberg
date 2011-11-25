Factory.sequence :project_name do |n|
  "project_#{n}"
end

Factory.sequence :build_number do |n|
  n
end

Factory.sequence :user_login do |n|
  n
end

Factory.define :project do |p|
  p.name { Factory.next(:project_name) }
  p.url  { |project| "git://domain/#{project.name}.git" }
  p.scm 'git'
  p.branch 'master'
end

Factory.define :build do |b|
  b.project { Factory(:project) }
  b.number  { Factory.next(:build_number) }
  b.revision "some_random_sha"
end

Factory.define :user do |u|
  u.login {Factory.next(:user_login)}
end

Factory.define :viewer, :class => :role do |r|
  r.user {|u| u.association(:user)}
  r.project {|p| p.association(:project)}
  r.role_type {|r| r.association(:role_type, :name => "viewer")}
end

Factory.define :builder, :class => :role do |r|
  r.user {|u| u.association(:user)}
  r.project {|p| p.association(:project)}
  r.role_type {|r| r.association(:role_type, :name => "builder")}
end

Factory.define :role_type do |r|
end
