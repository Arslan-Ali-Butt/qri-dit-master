class Tenant::ReportPhotosController < Tenant::BaseController
  authorize_resource class: false
  before_action :set_parent, only: [:index, :new, :create]
  before_action :set_resource, only: [:show, :edit, :update, :destroy, :print, :download]

  def index
    @resources = @parent.photos
  end

  def new
    @resource = @parent.photos.new
  end

  def create
    @resource = @parent.photos.new(resource_params)
    @resource.save
    respond_smart_with @resource, notice: 'Photo has been uploaded'
  end
  
  def print
    render partial: 'print'
  end

  def update
    @resource.update(resource_params)
    respond_smart_with @resource
  end
  
  def print
    render 'print', layout: false
  end

  def destroy
    begin
      @resource.destroy if @resource.report.sent_at.nil?
      respond_smart_with @resource
    rescue Exception => e
      respond_smart_with @resource, alert: e.message
    end
  end

  def download
    send_file @resource.photo.path, disposition: 'attachment'
  end
  
  def print
    render 'print', layout: false
  end

  private

  def set_parent
    @parent = Tenant::Report.find(params[:report_id])
  end

  def set_resource
    @resource = Tenant::ReportPhoto.find(params[:id])
  end

  def resource_params
    params.require(:tenant_report_photo).permit(:photo_url, :task_id)
  end
  
end
