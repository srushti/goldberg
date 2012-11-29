class BuildStatusMailer < ActionMailer::Base
  default :from => "build@goldberg.c42.in"

  def status_mail(from, to, subject, build)
    @build = build
    @project = build.project
    subject_line = subject || "#{@project.name} build #{build.status}"
    mail(:to => to, :subject => subject_line, :from => from)
  end
end
