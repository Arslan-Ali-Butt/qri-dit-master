class DestroyTenantWorker
  include Sidekiq::Worker

  def perform(id)
    Apartment::Tenant.drop("tenant#{id}")
  end
end
