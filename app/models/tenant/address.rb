class Tenant::Address < ActiveRecord::Base
  belongs_to :addressable, polymorphic: true
  
  attr_accessor :skip_validation

  with_options :if => :validation_needed? do |address|
    address.validates :house_number, presence: true
    address.validates :street_name, presence: true
    address.validates :city, presence: true
    address.validates :province, presence: true#, if: Proc.new { |o| %w(CA US).include? o.country and validation_needed? }
    address.validates :postal_code, presence: true, if: Proc.new { |o| %w(CA US).include? o.country and validation_needed? }
    address.validates :country, presence: true
  end

  strip_attributes allow_empty: true
  
  def validation_needed?
    result = true

    if self.respond_to?(:skip_validation) and self.skip_validation
      result = false
    end
    
    result
  end

  def to_s
    lines = []
    lines << "#{self.house_number}, #{self.street_name}"
    lines << self.line_2  if self.line_2.present?
    lines << self.city
    if province.present?
      lines << "#{self.province}, #{self.postal_code}"
    else
      lines << self.postal_code
    end
    c = Carmen::Country.coded(self.country)
    lines << c.name  if c
    lines.join("\n")
  end
end
