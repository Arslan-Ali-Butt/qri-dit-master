class Tenant::Support::Report
  include ActiveModel::Model

  attr_accessor :name, :email, :company, :message, :bug, :video, :screenshot, :browser, :browser_version, :os, :uri,:user_agent
  attr_reader :errors
  validates_presence_of :name, :email, :company, :message, :bug,  :video, :screenshot, :browser, :browser_version, :os, :uri,:user_agent

  def validate!
    @errors = ActiveModel::Errors.new(self)
    @errors.add(:message, "Please enter a detailed description of the bug.") unless self.message.present?
    @errors.add(:feature, "Please enter a terse description of the bug.") unless self.bug.present?
    @errors.count      
  end
end