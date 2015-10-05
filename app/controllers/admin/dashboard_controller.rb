class Admin::DashboardController < Admin::BaseController
  def index
    @landlords = Admin::Landlord.count
    @tenants = Admin::Tenant.count
  end
end
