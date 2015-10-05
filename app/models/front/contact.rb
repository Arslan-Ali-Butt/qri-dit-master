class Front::Contact
  include ActiveModel::Model

  attr_accessor :name, :email, :company, :zip, :source, :message
  attr_reader :errors
  validates_presence_of :name, :email, :company, :zip, :source, :message

  def validate!
    @errors = ActiveModel::Errors.new(self)
    @errors.add(:name, "Please enter your name.") if !name.present?
    @errors.add(:email, "Please enter your email.") if !email.present?
    @errors.add(:company, "Please enter your company name.") if !company.present?
    @errors.add(:zip, "Please enter your zip code.") if !zip.present?
    @errors.add(:source, "Please select how you found us.") if !source.present?
    @errors.add(:message, "Please enter your message.") if !message.present?
    @errors.count      
  end

end
