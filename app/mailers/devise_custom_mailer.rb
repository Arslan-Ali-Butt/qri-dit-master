# app/mailers/devise_custom_mailer.rb
class DeviseCustomMailer < Devise::Mailer
  if self.included_modules.include?(AbstractController::Callbacks)
    puts "Already included..."
  else
    include AbstractController::Callbacks
  end

  # Indicates we will add inline attachments
  before_filter :add_inline_attachment!

  private
  def add_inline_attachment!
    attachments.inline['bannerLogo.png'] = File.read("#{Rails.root}/app/assets/images/emails/emailBanner-Logo.png")
    attachments.inline['emailBanner.png'] = File.read("#{Rails.root}/app/assets/images/emails/emailBanner-NoText.png")
    attachments.inline['footerImage.png'] = File.read("#{Rails.root}/app/assets/images/emails/footerBottomImage.png")
  end
end
