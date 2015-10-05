class Admin::LandlordsController < Admin::BaseController
  include Crudable

  before_action :set_resource, only: [:show, :edit, :update, :destroy, :delete]

  def index
    @resources = Admin::Landlord.order(:name)
  end

  def new
    @resource = Admin::Landlord.new
  end

  def create
    @resource = Admin::Landlord.new(resource_params)
    @resource.save
    respond_smart_with @resource
  end

  def update
    @resource.update(resource_params)
    respond_smart_with @resource
  end

  private

  def set_resource
    @resource = Admin::Landlord.find(params[:id])
  end

  def resource_params
    params.require(:admin_landlord).permit(:name, :password, :password_confirmation)
  end
end
