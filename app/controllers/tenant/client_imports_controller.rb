class Tenant::ClientImportsController < Tenant::BaseController
  include Uploadable

  before_action :set_resource, only: [:edit, :update]

  def index
    #@current_import = 
    if session[:ongoing_import_id].present?
      @current_import = Tenant::ClientImport.find_by(id: session[:ongoing_import_id])

      if @current_import.nil?
        # the import doesn't exist for some reason
        session[:ongoing_import_id] = nil
      elsif @current_import.status == 1 
        # it was successful so no need to show the success message on the next page view
        session[:ongoing_import_id] = nil
      end
    end
  end

  def new
    @resource = Tenant::ClientImport.new

    setup_s3_upload
  end

  def edit
    setup_s3_upload
  end

  def create
    user_import_file = resource_params[:user_import_file]

    @resource = Tenant::ClientImport.create!(user_import_file: user_import_file)

    @resource.delay.import_users

    session[:ongoing_import_id] = @resource.id

    respond_smart_with nil, notice: 'Client import started successfully'
  end

  def update
    @resource.user_import_file = resource_params[:user_import_file]
    @resource.save!

    @resource.delay.import_users

    respond_smart_with nil, notice: 'Client import restarted successfully'
  end


  private
  def set_resource
    @resource = Tenant::ClientImport.find(params[:id])
  end

  def resource_params
    params.require(:tenant_client_import).permit(:user_import_file)
  end
end
