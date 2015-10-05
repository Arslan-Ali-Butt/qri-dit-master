class Tenant::StaffController < Tenant::UsersController

  def index
    super

    respond_to do |format|
      format.html
      format.json { 
        if params[:context] == 'datatables'
          render json: Tenant::StaffDatatable.new(view_context, @resources, @worked_this_week, current_user) 
        end
      }
    end 
  end

  def new
    @resource = Tenant::Staff.new
    @resource.build_address(country: 'CA')
    @resource.build_settings()
  end

  def create
    # User.invite! doesn't do honest validation (it saves user's roles even if user is invalid)
    # so we have a workaround here
    @resource = Tenant::Staff.new(resource_params)
    @resource.skip_password = true
    if @resource.valid?
      @resource = Tenant::Staff.invite!(resource_params, current_user)
    end
    respond_smart_with @resource, notice: "#{@resource.display_name} has been invited."
  end

  private
  def set_resource
    @resource = (role_name ? Tenant::Staff.by_role(role_name) : Tenant::Staff).find(params[:id])
  end
  
  def resource_params
    ret = params.require(:tenant_staff).permit(:name, :email, :phone_cell, :phone_landline, :phone_emergency, :phone_emergency_2, :client_type, :staff_daily_hours, :notes, :suspended_status, address_attributes: [:id, :house_number, :street_name, :line_2, :city, :province, :postal_code, :country], settings_attributes: [:id, :disable_assignment_notifications, :disable_report_notifications, :allow_reporting_with_no_assignment], staff_zone_ids: [], staff_work_type_ids: [], role_ids: [])
    ret[:role_ids] = [Tenant::Role.find_by!(name: role_name).id] if role_name
    ret.deep_merge({address_attributes:{:skip_validation => true}})
  end
end
