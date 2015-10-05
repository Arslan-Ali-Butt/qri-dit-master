require 'apartment/elevators/quick_report_systems'

Apartment.configure do |config|
  # these models will not be multi-tenanted, but remain in the global (public) namespace
  config.excluded_models = ['Admin::Landlord', 'Admin::Tenant', 'Admin::TenantNote', 'Admin::Priceplan', 'Admin::Logo', 
    'Admin::Priceplan::Addon', 'Admin::AffiliateChargifyResource']

  # the list of all databases required for migrations
  config.tenant_names = Proc.new { Admin::Tenant.table_exists? ? Admin::Tenant.pluck(:id).map { |id| "tenant#{id}" } : [] }

  config.seed_after_create = true
end

Rails.application.config.middleware.use 'Apartment::Elevators::QuickReportSystems'