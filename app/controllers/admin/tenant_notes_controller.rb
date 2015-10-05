class Admin::TenantNotesController < Admin::BaseController
  include Crudable

  before_action :set_parent, only: [:index, :new, :create]
  before_action :set_resource, only: [:show, :edit, :update, :destroy, :delete]

  def index
    redirect_to edit_admin_tenant_path(id: params[:tenant_id], show_tab: :edit_notes)
  end

  def new
    @resource = @parent.notes.new
  end

  def create
    @resource = @parent.notes.new(resource_params)
    @resource.save
    respond_smart_with @resource
  end

  def update
    @resource.update(resource_params)
    respond_smart_with @resource
  end

  private

  def set_parent
    @parent = Admin::Tenant.find(params[:tenant_id])
  end

  def set_resource
    @resource = Admin::TenantNote.find(params[:id])
  end

  def resource_params
    ret = params.require(:admin_tenant_note).permit(:title, :note)
    ret[:author_id] = session[:landlord_id]
    ret
  end
end
