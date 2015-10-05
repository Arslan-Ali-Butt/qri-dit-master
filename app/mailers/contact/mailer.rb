class Contact::Mailer < ActionMailer::Base
  default to: 'randy@quickreportsystems.com,jesse@quickreportsystems.com'
  
  def contact(resource)  
    @resource = resource
    mail from: @resource.email, subject: 'Contact Form Submission'
  end
end
