class Tenant::User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :registerable, :timeoutable, :lockable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable, :confirmable, :invitable, :async

  has_and_belongs_to_many :roles
  validates_presence_of :roles
  
  has_one :settings, class_name: 'Tenant::UserSettings', dependent: :destroy
  has_many :api_tokens, class_name: 'Tenant::ApiToken', autosave: true

  accepts_nested_attributes_for :settings

  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { in: 3..100 }
  #validates :email, presence: true, uniqueness: { :case_sensitive => false, :if => Proc.new { |obj| Admin::Tenant.find_by(:admin_email => obj.email).nil? && Tenant::User.find_by(:email => obj.email).nil? ? true : false }}, length: { in: 4..100 }, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }
  
  validates_confirmation_of :password, :message => "does not match password."
  
  after_initialize :set_defaults

  #after_save :rebuild_sphinx_index

  before_create :create_api_key
  
  def set_defaults
    self.skip_password = true
  end

  STATUSES = ['Active', 'Deleted', 'Suspended']
  validates :status, inclusion: { in: STATUSES }, allow_blank: true
  before_destroy :make_deleted
  strip_attributes allow_empty: true

  before_save do
    if self.roles.where(name: 'Admin').count > 0
      self.staff_work_type_ids = Tenant::WorkType.all.pluck(:id)
      self.staff_zone_ids = Tenant::Zone.all.pluck(:id)
    end
  end
  
  def display_name; "User#{self.name.present? ? " '#{self.name}'" : ''}" end

  def active_for_authentication?
    super && self.status == 'Active'
  end

  def self.by_role(role)
    joins(:roles).where(tenant_roles: {name: role}).distinct.readonly(false)
  end

  def self.active; where(status: 'Active') end

  def role?(role)
    self.roles.find_by(name: role.to_s.camelize).present?
  end

  def suspended_status; self.status == 'Suspended' end

  def suspended_status=(status); self.status = (status == '1' ? 'Suspended' : 'Active') end

  def create_api_key
    self.api_tokens << Tenant::ApiToken.new(token: generate_api_token)
  end

  def generate_api_token
    loop do
      token = SecureRandom.hex
      break token unless Tenant::ApiToken.exists?(token: token)
    end
  end

  def self.current_id
    Thread.current[:user_id]
  end

  def self.current_id=(user_id)
    Thread.current[:user_id] = user_id
  end

  private
  
  def rebuild_sphinx_index
    db = Apartment::Tenant.current_tenant
    ThinkingSphinx::RealTime.callback_for("user_#{db}".to_sym)
  end
  def make_deleted
    self.status='Deleted'
    false
  end
end