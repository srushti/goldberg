FactoryGirl.define do
  factory :project do |p|
    sequence(:name) { |n| "project_#{n}" }
    p.url  { |project| "git://domain/#{project.name}.git" }
    p.scm 'git'
    p.branch 'master'
    p.env_string ''
  end

  factory :build do |b|
    b.project { FactoryGirl.create(:project) }
    sequence(:number) { |n| n }
    b.revision "some_random_sha"
  end
end
