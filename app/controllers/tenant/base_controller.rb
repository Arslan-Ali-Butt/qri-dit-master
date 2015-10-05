class Tenant::BaseController < ApplicationController
  include Respondable

  around_action :set_timezone
  before_action :authenticate_user!
  before_action :set_current_user_for_thread
  before_action :set_tenant

  before_action { ActionMailer::Base.default_url_options = {host: request.host_with_port} }
  before_action { $HOST_WITH_PORT = request.host_with_port }
  
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to tenant_root_url, alert: exception.message
  end

  def current_ability
    @current_ability ||= Tenant::Ability.new(current_user)
  end

  private

    def set_tenant
      @tenant=Admin::Tenant.find(Apartment::Database.current_tenant.match(/\d+/).to_s.to_i)
    end

    def set_current_user_for_thread    
      Tenant::User.current_id = current_user.id unless current_user.blank? or not current_user.id      
    rescue
      # do nothing
    end
  
    def set_timezone
      tenant = Admin::Tenant.cached_find_by_host(request.host)

      if tenant and tenant.timezone
        Time.use_zone(tenant.timezone) { yield }
      else
        raise 'No default timezone defined.'
      end
    end
end
