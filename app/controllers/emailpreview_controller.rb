class EmailpreviewController < ApplicationController
  layout "emailbrand/email"
  prepend_view_path 'app/views/devise/mailer'

  def index
    @methods = self.action_methods
    render inline: "<% @methods.each do |p| %><p><a href='<%= p %>'><%= p %></a></p><% end %>"
  end

  def send_all
    Apartment::Database.switch("tenant#{Admin::Tenant.first.id}")
    @resource = Tenant::User.first()
    @recipient = Tenant::Staff.first()

    @report = Tenant::Report.new
    @report.id = 1
    @report.qrid = Tenant::Qrid.first
    @note = @report.notes.new
    @note2 = @report.notes.new

    @note.author_id = Tenant::User.first.id
    @note.report = @report
    @note2.author_id = Tenant::User.last.id
    @note2.report = @report

    @report.notes[0] = @note
    @report.notes[1] = @note2
    
    @author = @resource
    @report.reporter = @recipient
    @assignment = Tenant::Assignment.first

    puts "Delivering Assignment notification..."
    Tenant::Mailer.assignment_notification(@assignment).deliver

    puts "Delivering Assignment cancellation..."
    Tenant::Mailer.assignment_canceled_notification(@assignment).deliver

    puts "Delivering Report notification..."
    Tenant::Mailer.report_notification(@report, @recipient).deliver

    puts "Delivering C_Report Notification..."
    Tenant::Mailer.c_report_notification(@note).deliver

    puts "Delivering Reply Notification..."
    Tenant::Mailer.reply_notification(@note, @tenant).deliver

    puts "Delivering Welcome Notification..."
    Tenant::Mailer.welcome_message(@resource).deliver

    render inline: "OK."
  end

  def assignment_cancelled
    self.setup
    render "tenant/mailer/assignment_canceled_notification", layout: 'emailbrand/eblast'
  end

  def c_report_notification
    self.setup
    render "tenant/mailer/c_report_notification"
  end

  def reply_notification
    self.setup
    render "tenant/mailer/reply_notification"
  end

  def report_notification
    self.setup
    render 'tenant/mailer/report_notification', layout: 'emailbrand/eblast'
  end

  def welcome_message
    self.setup
    @omitFooter = true
    render 'tenant/mailer/welcome_message', layout: 'emailbrand/eblast'
  end

  def assignment_notification
    self.setup
    render "tenant/mailer/assignment_notification"
  end

  def confirmation_instructions
    self.setup

    render "devise/mailer/confirmation_instructions"
  end

  def unlock_instructions
    self.setup

    render "devise/mailer/unlock_instructions"
  end

  def reset_password_instructions
    self.setup

    render "devise/mailer/reset_password_instructions"
  end

  def invitation_instructions_su
    self.setup
    @resource.super_user = true
    @omitFooter = true
    render "devise/mailer/invitation_instructions"
  end

  def invitation_instructions_regular
    self.setup
    @resource.super_user = false
    render "devise/mailer/invitation_instructions"
  end
  def affiliate_request
    self.setup
    @tenant=Admin::Tenant.find_by_host(request.host)
    render "tenant/mailer/affiliate_request"
  end

  protected
  def setup
    if Apartment::Tenant.current_tenant=="public"
      Apartment::Database.switch("tenant#{Admin::Tenant.first.id}")
    else
      Apartment::Database.switch("tenant#{Admin::Tenant.find_by_host(request.host).id}")
    end
    @resource = Tenant::User.first()
    @recipient = @resource

    @report = Tenant::Report.new
    @report.qrid = Tenant::Qrid.first
    @report.notes.new
    @note = @report.notes.new
    @author = @resource
    @assignment = Tenant::Assignment.first
  end
end
