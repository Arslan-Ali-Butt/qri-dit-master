class Tenant::ClientsController < Tenant::UsersController
  append_before_action :get_reports, only: :show
  def index
    super

    @client_type = params[:client_type]
    @resources = @resources.where(client_type: @client_type) if @client_type.present?


    @site_id = params[:site_id]
    if @site_id.present?
      user_id = Tenant::Site.find(@site_id).try(:owner_id)
      @resources = @resources.where(id: user_id)
    end

    @city = params[:city]
    if @city.present?
      user_ids = []
      Tenant::Site.includes(:address).where('tenant_addresses.city = ?', @city).each do |site|
        user_ids << site.owner_id
      end
      @resources = @resources.where(id: user_ids)
    end

    @zone_id = params[:zone_id]
    if @zone_id.present?
      user_ids = []
      Tenant::Site.where(zone_id: @zone_id).each do |site|
        user_ids << site.owner_id
      end
      @resources = @resources.where(id: user_ids)
    end

    @qrid_id = params[:qrid_id]
    if @qrid_id.present?
      if site_id = Tenant::Qrid.find(@qrid_id).try(:site_id)
        user_id = Tenant::Site.find(site_id).try(:owner_id)
        @resources = @resources.where(id: user_id)
      else
        @resources = Tenant::Cient.none
      end
    end

    @work_type_id = params[:work_type_id]
    if @work_type_id.present?
      user_ids = []
      Tenant::Qrid.where(work_type_id: @work_type_id).each do |qrid|
        user_ids << Tenant::Site.find(qrid.site_id).try(:owner_id)
      end
      @resources = @resources.where(id: user_ids)
    end

    respond_to do |format|
      format.html
      format.json { 
        if params[:context] == 'datatables'
          render json: Tenant::ClientsDatatable.new(view_context, @resources) 
        end
      }
    end 
  end

  def new
    @resource = Tenant::Client.new
    @resource.build_address(country: 'CA')
    @resource.build_settings()
  end

  def create
    @resource = Tenant::Client.new(resource_params)

    if @resource.valid?

      @resource = Tenant::Client.invite!(resource_params, current_user) do |c|
        c.confirmed_at = Time.now.utc
        c.skip_invitation = Admin::Tenant.cached_find_by_host(request.host).try(:invite_clients_on_create) ? false : true        
      end

      respond_smart_with @resource, {notice: "#{@resource.display_name} has been created."}, new_tenant_site_url(owner_id: @resource.id, return_path: tenant_client_path(@resource))
    else
      respond_smart_with @resource#, notice: "#{@resource.display_name} has been created."
    end
  end

  private
  def set_resource
    @resource = (role_name ? Tenant::Client.by_role(role_name) : Tenant::Client).find(params[:id])
  end
  
  def resource_params
    ret = params.require(:tenant_client).permit(:name, :email, :phone_cell, :phone_landline, :phone_emergency, :phone_emergency_2, :client_type, :staff_daily_hours, :notes, :suspended_status, address_attributes: [:id, :house_number, :street_name, :line_2, :city, :province, :postal_code, :country], settings_attributes: [:id, :disable_assignment_notifications, :disable_report_notifications, :allow_reporting_with_no_assignment], staff_zone_ids: [], staff_work_type_ids: [], role_ids: [])
    ret[:role_ids] = [Tenant::Role.find_by!(name: role_name).id] if role_name
    ret
  end
  def get_reports
    @reports=Tenant::Report.joins(qrid: [:site]).where(tenant_sites: {:owner_id=>@resource.id}).where.not(submitted_at:nil).order(submitted_at: :desc).limit(75)
  end
  def role_name; 'Client' end
end
