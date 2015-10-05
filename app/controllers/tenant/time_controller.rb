class Tenant::TimeController < Tenant::BaseController
  authorize_resource class: false

  def index
    @resources = Tenant::Staff.by_role(['Admin', 'Manager', 'Reporter']).active

    @staff_zone_id = params[:staff_zone_id]
    @resources = @resources.includes(:staff_zones).where(tenant_zones: {id: @staff_zone_id}) if @staff_zone_id.present?

    @id = params[:id]
    @resources = @resources.where(id: @id) if @id.present?

    respond_to do |format|
      format.html
      format.json { 
        if params[:context] == 'datatables'
          render json: Tenant::TimeDatatable.new(view_context, @resources) 
        end
      }
    end 
  end

  def show
    @assignee = Tenant::Staff.by_role(['Admin', 'Manager', 'Reporter']).find(params[:id])
    @id = @assignee.id
  end
end
