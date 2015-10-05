class Admin::TenantsController < Admin::BaseController
  include Crudable

  before_action :set_resource, only: [:show, :edit, :update, :destroy, :delete]

  def index
    @resources = Admin::Tenant.order(:company_name)
  end

  def new
    @resource = Admin::Tenant.new
  end

  def create
    @resource = Admin::Tenant.new(resource_params)
    begin
      @resource.save
    rescue => ex
      flash.now[:alert] = 'An error occurred with our system during this process.  Please contact technical support : email support@quickreportsystems.com or phone 1-800-686-2104'
      raise ex
    end
    respond_smart_with @resource
  end

  def update
    subscription_id = @resource.process_upgrade_payment resource_params
    @resource.update({priceplan_id: resource_params[:priceplan_id], billing_subscription_id: subscription_id}.merge(update_params))
    respond_smart_with @resource
  end
  
  def resend
    id = params[:tenant_id]
    tenant = Admin::Tenant.find(id)
    if tenant
      Apartment::Tenant.switch("tenant#{id}")
      ActionMailer::Base.default_url_options = {host: tenant.host_url}
      @staff = Tenant::Staff.find_by(email: tenant.admin_email)
      @staff.invite!
      render 'resend', layout: false
    end    
  end

  private

  def set_resource
    @resource = Admin::Tenant.find(params[:id])
  end

  def update_params
    ret = params.require(:admin_tenant).permit(:subdomain, :company_name, :company_website, :name, :phone, :phone_ext, :admin_email)
    ret[:host_url] = request.host_with_port
    ret
  end
  
  def resource_params
    ret = params.require(:admin_tenant).permit(:subdomain, :company_name, :company_website, :name, :phone, :phone_ext, :admin_email, :priceplan_id, :card_token, :card_brand, :card_last4, :billing_recurrence, :payment_coupon)
    ret[:host_url] = request.host_with_port
    ret
  end
end
