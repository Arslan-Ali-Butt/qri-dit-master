class Tenant::AffiliatesController < Tenant::BaseController
  layout "tenant/affiliate", only: [:new, :confirmed,:create]
  before_action :set_owner
  before_action :set_resource, only: [:show, :edit, :update]
  skip_before_action :authenticate_user!, only: [:new, :create,:confirmed, :tac]

  def index
    @resources=Admin::Tenant.where(:parent_id=>@owner.id)
  end

  def new
    @resource=Admin::Tenant.new
  end

  def create
    @resource=Admin::Tenant.new(resource_params)
    @resource.priceplan=Admin::Priceplan.find_by_qrid_num(300)
    @resource.host_url = @resource.subdomain + '.' + request.host_with_port.sub(/^https?\:\/\//, '').sub(/^www./,'')
    @resource.affiliate_owner =@owner
    if @resource.save
      Tenant::Mailer.affiliate_request(Tenant::Staff.find_by_super_user(true),@resource).deliver
      render "confirmed"
    else
      render "new"
    end
  end
  def confirmed

  end
  def update
    pre_save_aproved=@resource.affiliate_status
    @resource.update_attributes(resource_params)
    if @resource.save
      @resource.create_tenant if (pre_save_aproved=="AWAITING_APPROVAL" && @resource.affiliate_status=="APPROVED") #TODO check if tenant Exists
      redirect_to tenant_affiliate_path(@resource)
    else
      render "edit"
    end
  end

  private
    def set_owner
      @owner=Admin::Tenant.cached_find_by_host(request.host)
    end
    def set_resource
      @resource=Admin::Tenant.find(params[:id])
    end
    def resource_params
      ret=params.require(:admin_tenant).permit(:subdomain,:company_name,:company_website,:name,:phone,:phone_ext,:admin_email,:timezone,:metric,:country_code,:affiliate_status)
    end
end
