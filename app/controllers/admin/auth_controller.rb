class Admin::AuthController < Admin::BaseController
  layout 'admin/auth'

  skip_before_action :authorize, only: :login

  def login
    if request.post?
      if landlord = Admin::Landlord.authenticate(params[:name], params[:password])
        reset_session     # session fixation countermeasures
        session[:landlord_id] = landlord.id
        redirect_to admin_root_url
      else
        flash.now[:alert] = "Invalid user/password combination"
      end
    else
      if session[:landlord_id]
        redirect_to admin_root_url
      end
    end
  end

  def logout
    reset_session
    redirect_to admin_login_url, notice: "Logged out"
  end
end
