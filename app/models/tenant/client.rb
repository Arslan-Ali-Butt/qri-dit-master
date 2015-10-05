class Tenant::Client < Tenant::User
  has_many :sites, foreign_key: :owner_id, dependent: :destroy, inverse_of: :owner
  validates_associated :address
  validates_associated :sites
  validates_presence_of :address
  has_one :address, as: :addressable, dependent: :destroy
  accepts_nested_attributes_for :address
  
  CLIENT_TYPES = %w(Residential Commercial)
  validates :client_type, inclusion: { in: CLIENT_TYPES, message: 'not selected.' }
  after_update :update_site_statuses!

  private

  def update_site_statuses!
    if self.status == 'Deleted'
      self.sites.where.not(status: 'Deleted').each do |site|
        site.update(status: 'Deleted')
      end
    elsif self.status == 'Active'
      self.sites.where.not(status: 'Active').each do |site|
        site.update(status: 'Active')
      end
    end
  end
end