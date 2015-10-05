class Admin::BaseController < ApplicationController
  include Respondable

  before_action :authorize

  private

  def authorize
    unless session[:landlord_id]
      redirect_to admin_login_url
    end
  end
end
