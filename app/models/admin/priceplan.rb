class Admin::Priceplan < ActiveRecord::Base
  has_many :tenants, dependent: :restrict_with_exception

  has_many :addons, class_name: "Admin::Priceplan::Addon"
  
  validates :name, presence: true, uniqueness: true
  validates :title, presence: true, uniqueness: true
  # validates :qrid_num, presence: true, uniqueness: true
  # validates :price_per_month, presence: true
  # validates :price_per_year, presence: true

  # NOTE
  # for the new (June 2015) QRID plans, qrid_num denotes the maximum number of QRIDs at the relevant pricing tier

  strip_attributes allow_empty: true
end
