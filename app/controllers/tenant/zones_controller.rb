class Tenant::ZonesController < Tenant::BaseController
  include Crudable

  authorize_resource class: false
  before_action :set_resource, only: [:edit, :update, :destroy, :delete]

  def index
    @resources = Tenant::Zone.order(:name)
  end

  def new
    @resource = Tenant::Zone.new
  end

  def create
    @resource = Tenant::Zone.new(resource_params)
    @resource.save
    respond_smart_with @resource
  end

  def update
    @resource.update(resource_params)
    respond_smart_with @resource
  end

  private

  def set_resource
    @resource = Tenant::Zone.find(params[:id])
  end

  def resource_params
    params.require(:tenant_zone).permit(:name, :notes)
  end
end
