class Tenant::Site < ActiveRecord::Base
  #include Statable

  has_paper_trail

  belongs_to :owner, class_name: 'Tenant::Client', foreign_key: :owner_id
  belongs_to :zone
  has_many :qrids, dependent: :destroy

  has_one :address, as: :addressable, dependent: :destroy
  accepts_nested_attributes_for :address
  validates_associated :address
  validates_presence_of :address

  validates :owner, presence: true

  STATUSES = ['Active', 'Deleted']
  validates :status, inclusion: { in: STATUSES }, allow_blank: true

  strip_attributes allow_empty: true

  before_save :copy_site_name!
  before_create :copy_owner_status!
  after_update :update_qrid_statuses!
  #after_save :rebuild_sphinx_index

  geocoded_by :full_street_address   # can also be an IP address

  # auto-fetch coordinates
  # after_validation :geocode, if: Proc.new { |site| site.latitude.blank? or site.longitude.blank? }           

  def display_name; 'Site' end

  def direction_url; "//maps.google.com/?daddr=#{self.latitude},#{self.longitude}" end

  def nearby?(latitude, longitude, accuracy)
    earthRadius=6371#in Kilometers
    lat1=(self.latitude.nil?)?0:self.latitude
    lon1=(self.longitude.nil?)?0:self.longitude
    lat2=(latitude.nil?)?0:latitude.to_f
    lon2=(longitude.nil?)?0:longitude.to_f
    d=Math.acos(Math.sin(lat1* Math::PI / 180 )*Math.sin(lat2* Math::PI / 180 )+\
    Math.cos(lat1* Math::PI / 180 )*Math.cos(lat2* Math::PI / 180 )*\
    Math.cos((lon2-lon1)* Math::PI / 180 ))
    dist=(d*earthRadius)*1000# 6371 is the average radius of the earth in Kilometers
    dist<=(300+accuracy.to_f)#300 meters + accuracy(meters)
    #true
  end

  def full_street_address
    self.address.to_s
  end

  def reports
    Tenant::Report.select('tenant_sites.created_at, tenant_users.name, tenant_reports.id').from('tenant_sites, tenant_reports, tenant_qrids, tenant_assignments, tenant_users').order(created_at: :desc).where('tenant_reports.assignment_id = tenant_assignments.id AND tenant_reports.reporter_id = tenant_users.id AND tenant_qrids.site_id = tenant_sites.id AND tenant_assignments.qrid_id = tenant_qrids.id AND tenant_sites.id = ' + id.to_s).map do |report|
      option = OpenStruct.new
      option.label = report.created_at.to_s + ' by ' + report.name
      option.id = report.id
      option
    end
  end

  def self.active; where(status: 'Active') end

  private

  def copy_owner_status!
    self.status = self.owner.status
  end

  def copy_site_name!
    self.name = self.address.street_name + ' ' + self.address.house_number
  end

  def update_qrid_statuses!
    if self.status == 'Deleted'
      self.qrids.where.not(status: 'Deleted').each do |qrid|
        qrid.update(status: 'Deleted')
      end
    end
  end

  def rebuild_sphinx_index
    db = Apartment::Tenant.current_tenant
    ThinkingSphinx::RealTime.callback_for("site_#{db}".to_sym)
  end
end
