class BuildMailNotification
  def initialize(build)
    @build = build
  end

  def from(from)
    @from = from
    self
  end

  def to(to)
    @to = to
    self
  end

  def with_subject(subject)
    @subject = subject
    self
  end

  def send
    BuildStatusMailer.status_mail(@from, @to, @subject, @build).deliver
  end
end
