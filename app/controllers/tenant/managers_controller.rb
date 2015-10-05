class Tenant::ManagersController < Tenant::UsersController
  def create
    # User.invite! doesn't do honest validation (it saves user's roles even if user is invalid)
    # so we have a workaround here
    @resource = Tenant::Staff.new(resource_params)
    @resource.skip_password = true
    if @resource.valid?
      @resource = Tenant::Staff.invite!(resource_params, current_user)
    end
    respond_smart_with @resource, notice: "#{@resource.display_name} has been invited."
  end
  private
  def role_name; 'Manager' end
end
