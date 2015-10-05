class Tenant::UpdateQridsOnPlanWorker
  
  include Sidekiq::Worker

  def perform
    m = Apartment::Tenant.current_tenant.match(/\d+/)
    tenant = Admin::Tenant.find(m[0])

    if !tenant.is_affiliate?
      product_family = Chargify::ProductFamily.find_by_handle('public-pricing-plans')

      qrids_component = product_family.components.first

      subscription = Chargify::Subscription.find(tenant.billing_subscription_id)

      if !subscription.trial_ended_at.nil? && subscription.trial_ended_at <= Time.now
        # the honeymoon is over

        allocation = Chargify::Allocation.create(subscription_id: subscription.id, component_id: qrids_component.id, 
          quantity: Tenant::Qrid.where(status: 'Active').count, memo: "New QRID created on #{Time.now.strftime('%Y-%m-%d %H:%M:%S %z')}", 
          proration_upgrade_scheme: 'full-price-delay-capture', proration_downgrade_scheme: 'no-prorate')
      end
    else
      product_family = Chargify::ProductFamily.find_by_handle('affiliate-pricing-plans')

      #qrids_component = product_family.components.first

      subscription = Chargify::Subscription.find(tenant.affiliate_owner.billing_subscription_id)

      if !subscription.trial_ended_at.nil? && subscription.trial_ended_at <= Time.now
        # the honeymoon is over

        allocation = Chargify::Allocation.create(subscription_id: subscription.id, 
          component_id: tenant.affiliate_chargify_resource.qrids_component_id, 
          quantity: Tenant::Qrid.where(status: 'Active').count, memo: "New QRID created on #{Time.now.strftime('%Y-%m-%d %H:%M:%S %z')}", 
          proration_upgrade_scheme: 'full-price-delay-capture', proration_downgrade_scheme: 'no-prorate')
      end

    end
    
  end
end