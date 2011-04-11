Factory.sequence :project_name do |n|
  "project_#{n}"
end

Factory.define :project do |p|
  p.name { Factory.next(:project_name) }
  p.url  { |project| "git://domain/#{project.name}.git" }
  p.branch 'master'
end

Factory.define :build do |b|
  b.project { Factory(:project) }
  b.revision "some_random_sha"
end

