class Admin::Tenant < ActiveRecord::Base
  belongs_to :priceplan
  has_many :notes, class_name: 'Admin::TenantNote', dependent: :destroy
  has_one :logo, dependent: :destroy
  belongs_to :affiliate_owner, :class_name=> "Admin::Tenant", :foreign_key => "parent_id"
  has_many :affiliates, :class_name=> "Admin::Tenant", :foreign_key => "parent_id"

  has_one :affiliate_chargify_resource, class_name: 'Admin::AffiliateChargifyResource', dependent: :destroy

  attr_accessor :card_token, :billing_coupon,:cardholder_telephone,:billingaddress_line1,:billingaddress_line2,:billingaddress_city,:billingaddress_state,:billingaddress_zip,:billingaddress_country
  attr_accessor :first_name,:last_name
  attr_accessor :tac
  
  AFFILIATE_STATUSES = %w(APPROVED AWAITING_APPROVAL DENIED)
  SPECIAL_SUBDOMAINS = %w(www admin public mail ftp smtp imap webmail cpanel webmin http https qridit homewatch qridit-homewatch-edition)
  PAYMENT_RECURRENCE = %w(month year)

  def self.index_of_payment_recurrence(recurrence)
    PAYMENT_RECURRENCE.index(recurrence)
  end

  def is_affiliate?
    !affiliate_owner.nil?
  end
  
  def is_affiliate_owner?
    allow_affiliate_requests
  end

  validates :company_name, presence: true, length: { in: 2..100 }
  validates :company_website, length: { maximum: 100 }, allow_blank: true
  validates :name, presence: true, length: { in: 3..100 }
  validates :phone, length: { maximum: 30 }
  validates :phone_ext, length: { maximum: 10 }

  validates :admin_email, presence: true, uniqueness: { :case_sensitive => false, :if => Proc.new { |obj| Admin::Tenant.find_by(:admin_email => obj.admin_email).nil? }}, length: { in: 4..100 }, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }

  validates :subdomain, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/, message: 'must contain only lowercase letters, digits and dashes' }, exclusion: { in: SPECIAL_SUBDOMAINS }, length: { in: 3..20 }

  validates :priceplan_id, presence: true, unless: :is_affiliate?
  validates :billing_recurrence, presence: true, unless: :is_affiliate?

  strip_attributes allow_empty: true

  before_create :process_payment, if: Proc.new { !Rails.env.test? && !is_affiliate? }
  before_update :flush_cache
  before_destroy :flush_cache

  def create_tenant
    if Rails.env.test?
      CreateTenantWorker.new.perform(self.id)
    else
      CreateTenantWorker.perform_async(self.id)
    end
  end

  after_create :create_tenant, unless: :is_affiliate?
  
  after_destroy { |r| Rails.env.test? ? DestroyTenantWorker.new.perform(r.id) : DestroyTenantWorker.perform_async(r.id) }

  before_validation { |t| t.name = (t.name.blank?)?"#{t.first_name} #{t.last_name}":t.name }

  def display_name; "Tenant#{self.company_name.present? ? " '#{self.company_name}'" : ''}" end

  def self.cached_find_by_host(host)
    if true
      return self.find_by_host(host)
    end
    subdomain = host.split('.').first
    return nil if SPECIAL_SUBDOMAINS.include? subdomain
    tenant = Rails.cache.read([name, subdomain])
    unless tenant
      tenant = Admin::Tenant.find_by(subdomain: subdomain)
      Rails.cache.write([name, subdomain], tenant) if tenant
    end
    tenant
  end

  def self.find_by_host(host)
    subdomain = host.split('.').first
    return nil if SPECIAL_SUBDOMAINS.include? subdomain
    tenant = Admin::Tenant.find_by(subdomain: subdomain)    
    tenant
  end

  def payments
    ChargeBee::Transaction.list(customer: @payment_customer_id)
  end

  def process_payment
    # opts = {
    #   :plan_id => 'qridit_home_watch_edition_' + Admin::Priceplan.find(self.priceplan.id).name + '_' + Admin::Tenant::PAYMENT_RECURRENCE[self.billing_recurrence.to_i],
    #   :customer => {
    #     :email => self.admin_email,
    #     # :first_name => self.cardholder_firstname,
    #     # :last_name => self.cardholder_lastname,
    #     :phone => self.cardholder_telephone
    #   },
    #   :card => {
    #       :gateway => :stripe.to_s,
    #       :tmp_token => self.card_token
    #   }
    # }

    customer = Stripe::Customer.create(
      :description => "#{self.name} - #{self.admin_email}",
      :source => self.card_token # obtained with Stripe.js
    )

    # opts[:coupon] = self.billing_coupon if self.billing_coupon && CouponValidator.active?(self.billing_coupon, self.admin_email)
    # tax_table_file = File.join(Rails.root, 'config', 'taxes.yml')      
    # tax_table = YAML.load(File.open(tax_table_file)) if File.exists?(tax_table_file)
    # if self.billingaddress_country == 'CA'
    #   opts[:addons] = []
    #   tax_table[self.billingaddress_state][%w(month year)[self.billing_recurrence.to_i]][Admin::Priceplan.find(self.priceplan_id).name].each do |tax|
    #     opts[:addons] += [{:id => tax}]
    #   end
    # end
    coupon = CouponValidator.active?(self.billing_coupon, self.admin_email) ? self.billing_coupon : nil

    subscription = Chargify::Subscription.create(product_handle: 'qridit-base-plan', customer_attributes: { 
      first_name: self.first_name, last_name: self.last_name, email: self.admin_email, organization: company_name, 
      address: billingaddress_line1, address_2: billingaddress_line2, city: billingaddress_city, state: billingaddress_state, 
      zip: billingaddress_zip, country: billingaddress_country}, coupon_code: coupon, payment_profile_attributes: 
      { current_vault: 'stripe', vault_token: customer.id, last_four: self.card_last4, card_type: self.card_brand.downcase })


    self.billing_subscription_id = subscription.id
    self.billing_customer_id = subscription.customer.id
  end

  def process_change_plan(change_plan_params)
    # there are no more plans to change
    # TODO remove function altogether
   # opts = {
   #    :plan_id => 'qridit_home_watch_edition_' + Admin::Priceplan.find(change_plan_params[:priceplan_id]).name + '_' + change_plan_params[:billing_recurrence],
   #    :prorate => true,
   #    :card => {
   #      :gateway => :stripe.to_s,
   #      :tmp_token => change_plan_params[:card_token]
   #    }
   #  }

   #  opts[:coupon] = change_plan_params[:billing_coupon] if change_plan_params[:billing_coupon]
   #  tax_table_file = File.join(Rails.root, 'config', 'taxes.yml')      
   #  tax_table = YAML.load(File.open(tax_table_file)) if File.exists?(tax_table_file)
   #  if self.billingaddress_country == 'CA'
   #    opts[:replace_addon_list] = true
   #    opts[:addons] = []
   #    tax_table[self.billingaddress_state][change_plan_params[:billing_recurrence]][Admin::Priceplan.find(change_plan_params[:priceplan_id]).name].each do |tax|
   #      opts[:addons] += [{:id => tax}]
   #    end
   #  end
   
   #  result = ChargeBee::Subscription.update(self.billing_subscription_id,opts)
   #  self.billing_subscription_id = result.try(:subscription).try(:id)
   #  self.billing_subscription_id
  end

  def company_uri
    co_website = self.company_website.chomp("/")
    co_uri = URI::HTTP.build(host: co_website) unless co_website.blank?
  end

  protected
  
  def prepare_to_save
    self.flush_cache
    if self.subdomain.present?
      self.host_url = "#{self.subdomain}.#{$HOST_WITH_PORT.sub(/^https?\:\/\//, '').sub(/^www./,'')}"
    end
  end

  def flush_cache
    Rails.cache.delete([self.class.name, self.subdomain])
  end
end
