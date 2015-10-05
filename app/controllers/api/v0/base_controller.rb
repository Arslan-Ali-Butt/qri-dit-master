class Api::V0::BaseController < ApplicationController
  skip_before_action :verify_authenticity_token

  around_action :set_timezone

  before_filter :check_auth

  before_action :check_features

  def check_auth
    do_authentication || render_unauthorized
  end


  def do_authentication
    success = false

    if request.env['HTTP_AUTHORIZATION'].present?
      success = (authenticate_with_http_basic do |username, password|
        puts "username: \\#{username}\\"
        @current_user = Tenant::User.find_by_email(username)
        if @current_user.present? and @current_user.valid_password?(password)
          #sign_in Tenant::User, @current_user, store: false
          true
        end
      end)
    elsif request.env['HTTP_X_API_KEY'].present?
      # TODO implement token based authentication here

      api_token = Tenant::ApiToken.find_by(token: request.env['HTTP_X_API_KEY'])
      @current_user = api_token.try(:user)
      if @current_user
        success = true
      end

    end

    success
  end

  def current_user
    @current_user
  end

  def current_ability
    @current_ability ||= Tenant::Ability.new(@current_user)
  end

  def render_unauthorized
    self.headers['WWW-Authenticate'] = 'Basic Realm="Application"'

    respond_to do |format|
      format.json { render json: {errors: 'Invalid email, password or api token' }, status: 401 }
    end
  end

  private

  def set_timezone
    @tenant = Admin::Tenant.cached_find_by_host(request.env['HTTP_X_COMPANY_DOMAIN'])
    puts "domain \\#{request.env['HTTP_X_COMPANY_DOMAIN']}\\"
    if @tenant and @tenant.timezone
      Time.use_zone(@tenant.timezone) { yield }
    elsif @tenant.nil?
      render_unauthorized
    else
      raise 'No default timezone defined.'
    end
  end
  def check_features
    @features={}
    if request.env['HTTP_X_API_FEATURES'].present?
      @features.merge!(lft_right: (request.env['HTTP_X_API_FEATURES'].include?('lft_right')?true:false))
      @features.merge!(flat_task_list: (request.env['HTTP_X_API_FEATURES'].include?('flat_task_list')?true:false))
      @features.merge!(full_site: (request.env['HTTP_X_API_FEATURES'].include?('full_site')?true:false))
    end
  end
end
