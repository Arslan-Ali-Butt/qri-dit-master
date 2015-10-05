class Tenant::Mailer < ActionMailer::Base
  default from: 'noreply@qridithomewatch.com'

  # The default layout for all emails sent by the system
  # is the plain email template. For emails which require
  # the logo at the top, the e-blast template should be used.
  layout 'emailbrand/email'

  # Sends the Assignment Notification email to a client.
  # This e-mail uses the E-Blast template.
  def assignment_notification(assignment)
    self.setup_attachments()
    @assignment = assignment
    @recipient = @assignment.assignee
    return if @recipient.settings && @recipient.settings.disable_assignment_notifications

    mail(to: @recipient.email, subject: 'New Assignment Notification') do |format|
      format.html { render layout: 'emailbrand/eblast' }
      format.text
    end
  end

  # Sends the Assignment Cancelled Notification email to a client.
  # This e-mail uses the E-Blast template.
  def assignment_canceled_notification(assignment)
    self.setup_attachments()
    @assignment = assignment
    @recipient = @assignment.assignee
    return if @recipient.settings && @recipient.settings.disable_assignment_notifications

    mail(to: @recipient.email, subject: 'Assignment Cancelation') do |format|
      format.html { render layout: 'emailbrand/eblast' }
      format.text
    end
  end

  # Sends the New Report Notification email to a client.
  # This e-mail uses the E-Blast template.
  def report_notification(report, recipient)
    self.setup_attachments()
    @recipient = recipient
    return if @recipient.settings && @recipient.settings.disable_report_notifications

    @report = report
    @author = @report.reporter
    mail(to: @recipient.email, subject: 'New Report Submission') do |format|
      format.html { render layout: 'emailbrand/eblast' }
      format.text
    end
  end

  # Sends the C New Report Notification email to a client.
  def c_report_notification(note)
    self.setup_attachments()
    @note = note
    @author = Tenant::User.find(note.author_id)
    @report = note.report
#    @report.photos.each do |photo|
#      attachments.inline[photo.photo.original_filename] = File.read(photo.photo.path(:medium))
#    end
    @recipient = @report.qrid.site.owner
    return if (@recipient.settings && @recipient.settings.disable_report_notifications) || @recipient.invitation_accepted_at.blank?

    if Tenant::ReportNote.where(report_id: @report).count > 1
      mail(to: @recipient.email, subject: ' A new Comment on your Report') do |format|
        format.html { render layout: 'emailbrand/email' }
        format.text
      end
    else
      mail(to: @recipient.email, subject: 'You have Received a new Report') do |format|
        format.html { render layout: 'emailbrand/email' }
        format.text
      end
    end
  end

  # Sends the Report Reply Notification to a client.
  def reply_notification(note, tenant)
    self.setup_attachments()
    @note = note
    @author = Tenant::User.find(note.author_id)
    @report = note.report

    @recipient = @author
    mail(to: @author.email, subject: 'A new Comment on your Report') do |format|
      format.html { render layout: 'emailbrand/email' }
      format.text
    end

    reply_to = @report.notes.where.not(author_id: note.author_id).order(created_at: :desc).first
    if reply_to.present? and tenant.allow_comment_email_notifications
      @recipient = Tenant::User.find(reply_to.author_id)
      return if @recipient.settings && @recipient.settings.disable_report_notifications

      mail(to: @recipient.email, subject: 'A new Comment on your Report') do |format|
        format.html { render layout: 'emailbrand/email' }
        format.text
      end
    end
  end

  # Sends the Welcome Message to a client.
  # This e-mail uses the E-Blast template.
  def welcome_message(recipient)
    self.setup_attachments()
    @recipient = recipient
    mail(to: @recipient.email, subject: 'Your QRIDit Home Watch Edition Account Information') do |format|
      format.html { render layout: 'emailbrand/eblast' }
      format.text
    end
  end

  def affiliate_request(recipient,tenant)
    self.setup_attachments()
    @recipient = recipient
    @tenant=tenant
    mail(to: @recipient.email, subject: 'Someone has requested to be your Affiliate') do |format|
      format.html { render layout: 'emailbrand/email' }
      format.text
    end
  end
  protected

  def setup_attachments()
    attachments.inline['bannerLogo.png'] = File.read("#{Rails.root}/app/assets/images/emails/emailBanner-Logo.png")
    attachments.inline['emailBanner.png'] = File.read("#{Rails.root}/app/assets/images/emails/emailBanner-NoText.png")
    attachments.inline['footerImage.png'] = File.read("#{Rails.root}/app/assets/images/emails/footerBottomImage.png")
  end
end
