require 'spec_helper'

describe BuildMailNotification do
  it "can send mail in a DSLish syntax" do
    build = double(project: 'project')
    mail = double
    notification = BuildMailNotification.new(build)
    BuildStatusMailer.should_receive(:status_mail).with('from','to','some subject',build).and_return(mail)
    mail.should_receive(:deliver)

    notification.from('from').to('to').with_subject('some subject').send
  end
end
