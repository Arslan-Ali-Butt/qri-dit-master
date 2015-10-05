class CreateTenantWorker
  include Sidekiq::Worker

  def perform(id)
    tenant = Admin::Tenant.find(id)
    if tenant
      host_url = tenant.host_url.sub(/^https?\:\/\//, '').sub(/^www\./,'')
      Apartment::Tenant.create("tenant#{id}")
      Apartment::Tenant.switch("tenant#{id}")
      ActionMailer::Base.default_url_options = {host: host_url}

      Tenant::Staff.invite!(
          role_ids: [Tenant::Role.find_by!(name: 'Admin').id],
          email: tenant.admin_email,
          name: tenant.name,
          super_user: true
      )

      if tenant.is_affiliate?
        if tenant.affiliate_chargify_resource.nil?
          chargify_resource = Admin::AffiliateChargifyResource.new
        else
          chargify_resource = tenant.affiliate_chargify_resource
        end
        product_family = Chargify::ProductFamily.find_by_handle('affiliate-pricing-plans')

        if chargify_resource.base_component_id.nil? || chargify_resource.base_component_id.blank?
          component = Chargify::ProductFamily::Component.create(name: "Admin Fee - #{tenant.company_name} (created at #{Time.now.utc.strftime('%Y%m%d%H%M%S')}) ",
          description: 'The admin fee for affiliates', product_family_id: product_family.id,
          kind: 'on_off_component', taxable: true, unit_price: 20.00)

          chargify_resource.base_component_id = component.id
        end

        if chargify_resource.qrids_component_id.nil? || chargify_resource.base_component_id.blank?
          component = Chargify::ProductFamily::Component.create(name: "QRIDs - #{tenant.company_name} (created at #{Time.now.utc.strftime('%Y%m%d%H%M%S')})",
                                                                description: "The maximum number of QRIDs used in a monthly
            billing period by #{tenant.company_name}", unit_name: 'qrid', pricing_scheme: 'tiered',
                                                                prices: [{ starting_quantity: 1, ending_quantity: nil, unit_price: 1.25 }],
                                                                product_family_id: product_family.id, kind: 'quantity_based_component', taxable: true)

          chargify_resource.qrids_component_id = component.id
        end
        chargify_resource.save
        tenant.affiliate_chargify_resource = chargify_resource
        tenant.save

        subscription = Chargify::Subscription.find(tenant.affiliate_owner.billing_subscription_id)

        allocation = Chargify::Allocation.create(subscription_id: subscription.id,
                                                 component_id: tenant.affiliate_chargify_resource.base_component_id,
                                                 quantity: 1, memo: "Affiliate base fee applied",
                                                 proration_upgrade_scheme: 'full-price-delay-capture', proration_downgrade_scheme: 'no-prorate')

        allocation = Chargify::Allocation.create(subscription_id: subscription.id,
                                                 component_id: tenant.affiliate_chargify_resource.qrids_component_id,
                                                 quantity: 0, memo: "Affiliate bootstrapped with the allocated number of QRIDs on #{Time.now.strftime('%Y-%m-%d %H:%M:%S %z')}",
                                                 proration_upgrade_scheme: 'full-price-delay-capture', proration_downgrade_scheme: 'no-prorate')
      end

      Apartment::Tenant.switch
    end
  end
end
