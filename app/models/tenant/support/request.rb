class Tenant::Support::Request
  include ActiveModel::Model

  attr_accessor :name, :email, :company, :message, :screenshot
  attr_reader :errors
  validates_presence_of :name, :email, :company, :message, :screenshot

  def validate!
    @errors = ActiveModel::Errors.new(self)
    @errors.add(:message, "Please enter a detailed description of the feature.") unless self.message.present?    
    @errors.count 
  end
end
