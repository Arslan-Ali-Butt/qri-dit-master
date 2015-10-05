class Tenant::SitesController < Tenant::BaseController
  authorize_resource class: false
  before_action :set_resource, only: [:show, :edit, :update, :destroy, :delete]

  def index
    @resources = Tenant::Site.includes(:owner, :address, :zone)

    @owner_id ||= params[:owner_id]
    @resources = @resources.where(owner_id: @owner_id) if @owner_id.present?

    @client_type = params[:client_type]
    @resources = @resources.where('tenant_users.client_type = ?', @client_type) if @client_type.present?

    @city = params[:city]
    @resources = @resources.includes(:address).where('tenant_addresses.city = ?', @city) if @city.present?

    @zone_id = params[:zone_id]
    @resources = @resources.where(zone_id: @zone_id) if @zone_id.present?

    @status = params[:status] || 'Active'
    @resources = @resources.where(status: @status) if @status.present?

    @id = params[:id]
    @resources = @resources.where(id: @id) if @id.present?

    respond_to do |format|
      format.html
      format.json { 
        if params[:context] == 'datatables'
          render json: Tenant::SitesDatatable.new(view_context, @resources) 
        end
      }
    end 
  end

  def new
    @resource = Tenant::Site.new
    @resource.owner_id = params[:owner_id].to_i  if params[:owner_id]
    @resource.build_address(country: 'CA')
  end

  def edit
    @resource.build_address(country: 'CA') unless @resource.address
  end

  def create
    @resource = Tenant::Site.new(resource_params)
    @resource.save
    respond_smart_with @resource
  end

  def update
    @resource.update(resource_params)
    respond_smart_with @resource
  end

  def destroy
    case params[:opt]
      when 'destroy'
        begin
          @resource.destroy
          respond_smart_with @resource
        rescue Exception => e
          respond_smart_with @resource, alert: e.message
        end
      when 'disable'
        @resource.update(status: 'Deleted')
        respond_smart_with @resource, notice: "#{@resource.display_name} has been disabled."
    end
  end

  private

  def set_resource
    @resource = (@owner_id ? Tenant::Site.where(owner_id: @owner_id) : Tenant::Site).find(params[:id])
  end

  def resource_params
    ret = params.require(:tenant_site).permit(:owner_id, :zone_id, :latitude, :longitude, :alarm_code, :alarm_safeword, :alarm_company, :emergency_number, :notes, :instruction , address_attributes: [:id, :house_number, :street_name, :line_2, :city, :province, :postal_code, :country])
    ret[:owner_id] = @owner_id if @owner_id
    ret
  end
end
