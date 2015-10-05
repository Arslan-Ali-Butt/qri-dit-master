require 'digest/sha2'

class Admin::Landlord < ActiveRecord::Base
  attr_accessor :password, :password_confirmation

  validates :name,      presence: true, uniqueness: true, length: {in: 2..20}
  validates :password,  presence: true, confirmation: true, length: {in: 10..200}
  validates :password_confirmation, presence: true

  strip_attributes allow_empty: true

  before_save :hash_password!
  after_destroy :check_last_landlord

  def display_name; "Landlord#{self.name.present? ? " '#{self.name}'" : ''}" end

  def self.authenticate(name, password)
    if (landlord = self.find_by(name: name))
      if landlord.hashed_password == self.encrypted_password(password, landlord.salt)
        landlord.update_columns(last_login_at: Time.current)
      else
        landlord = nil
      end
    end
    landlord
  end

  protected

  def hash_password!
    if @password.present?
      self.salt = SecureRandom.base64(8)
      self.hashed_password = self.class.encrypted_password(@password, self.salt)
    end
  end

  def check_last_landlord
    if self.class.count.zero?
      raise "There should be at least one landlord. Cannot delete the last one."
    end
  end

  private

  def self.encrypted_password(password, salt)
    Digest::SHA2.hexdigest("#{password}wibble#{salt}")
  end
end
