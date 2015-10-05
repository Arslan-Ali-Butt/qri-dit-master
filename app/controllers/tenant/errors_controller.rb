class Tenant::ErrorsController < Tenant::BaseController
  skip_around_action :set_timezone
  skip_before_action :authenticate_user!

  def show
    status_code = params[:code] || 500
    render status_code.to_s, status: status_code
  end
end
