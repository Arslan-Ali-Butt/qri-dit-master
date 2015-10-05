class Tenant::WorkTypesController < Tenant::BaseController
  include Crudable

  authorize_resource class: false
  before_action :set_resource, only: [:edit, :update, :destroy, :delete]

  def index
    @resources = Tenant::WorkType.order(:name)
  end

  def new
    @resource = Tenant::WorkType.new
  end

  def create
    @resource = Tenant::WorkType.new(resource_params)
    @resource.save
    respond_smart_with @resource
  end

  def update
    @resource.update(resource_params)
    respond_smart_with @resource
  end

  private

  def set_resource
    @resource = Tenant::WorkType.where(fixed: false).find(params[:id])
  end

  def resource_params
    params.require(:tenant_work_type).permit(:name)
  end
end
