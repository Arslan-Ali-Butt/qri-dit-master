class Tenant::AccountController < Devise::RegistrationsController
  undef_method :new, :create, :destroy, :cancel

  layout 'tenant/base'

  def show
    authenticate_scope!
    self.resource = current_user
  end
end
