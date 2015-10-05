class Tenant::QridPhotosController < Tenant::BaseController
  include Crudable
  include Uploadable
  
  authorize_resource class: false
  before_action :set_parent, only: [:index, :new, :create]
  before_action :set_resource, only: [:show, :edit, :update, :destroy, :print, :download]

  def index
    @resources = @parent.photos
  end

  def new
    @resource = @parent.photos.new
    
    setup_s3_upload
  end
  
  def print
    render partial: 'print'
  end

  def create
    @resource = @parent.photos.new(resource_params)
    @resource.save
    respond_smart_with @resource, notice: 'Photo added successfully'
  end

  def update
    @resource.update(resource_params)
    respond_smart_with @resource
  end

  def download
    send_file @resource.photo.path, disposition: 'attachment'
  end
  
  def print
    render 'print', layout: false
  end

  private

  def set_parent
    @parent = Tenant::Qrid.find(params[:qrid_id])
  end

  def set_resource
    @resource = Tenant::QridPhoto.find(params[:id])
  end

  def resource_params
    params.require(:tenant_qrid_photo).permit(:photo_url, :title, :description, :qrid_id)
  end
end
