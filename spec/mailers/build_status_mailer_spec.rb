require "spec_helper"

describe BuildStatusMailer do
  context "build status mail" do
    it "takes a default subject line" do
      build = Factory.create(:build, :status => 'passed')
      BuildStatusMailer.status_mail('from','to',nil,build).deliver
      ActionMailer::Base.deliveries.first.subject.should == "#{build.project.name} build #{build.status}"
    end
  end
end
