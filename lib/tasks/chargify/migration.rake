namespace :chargify do
  namespace :migration do

    desc "Seed the application database with the new price plans"
    task seed: :environment do
      priceplan = Admin::Priceplan.create_with(title: 'Qridit Base Plan', qrid_num: nil, price_per_month: 40.00, price_per_year: nil, position: 1).find_or_create_by!(name: 'qridit-base-plan')

      Admin::Priceplan::Addon.create_with(name: 'Startup', item_name: 'qrid', starting_number: 1, ending_number: 3, unit_price: 0.00, priceplan: priceplan).find_or_create_by(name: 'Startup', item_name: 'qrid', starting_number: 1, ending_number: 3)
      Admin::Priceplan::Addon.create_with(name: 'Entrepreneur', item_name: 'qrid', starting_number: 4, ending_number: 50, unit_price: 2.50, priceplan: priceplan).find_or_create_by(name: 'Entrepreneur', item_name: 'qrid', starting_number: 4, ending_number: 50)
      Admin::Priceplan::Addon.create_with(name: 'Business', item_name: 'qrid', starting_number: 51, ending_number: 250, unit_price: 1.99, priceplan: priceplan).find_or_create_by(name: 'Business', item_name: 'qrid', starting_number: 51, ending_number: 250)
      Admin::Priceplan::Addon.create_with(name: 'Corporate', item_name: 'qrid', starting_number: 251, ending_number: 350, unit_price: 1.75, priceplan: priceplan).find_or_create_by(name: 'Corporate', item_name: 'qrid', starting_number: 251, ending_number: 350)
      Admin::Priceplan::Addon.create_with(name: 'Corporate Plus', item_name: 'qrid', starting_number: 351, ending_number: 9999, unit_price: 1.50, priceplan: priceplan).find_or_create_by(name: 'Corporate Plus', item_name: 'qrid', starting_number: 351, ending_number: 9999)
    end

    desc "Create the public pricing plan available on the website on Chargify"
    task create_public_plans: :environment  do

      # old pricing plans
      old_product_family = Chargify::ProductFamily.create(name: 'Legacy Pricing Plans', 
        description: 'These are the plans the original pricing plans used by tenants created on or before June 15, 2015')

      secret_starter_monthly = Chargify::Product.create(name: 'Secret Starter - Monthly', price_in_cents: 3500, 
        description: 'The secret starter plan billed per month', 
        product_family_id: old_product_family.id, interval_unit: 'month', interval: 1, initial_charge_in_cents: 0, trial_price_in_cents: 0, 
        trial_interval: 1, trial_interval_unit: 'month', taxable: true, 
        trial_type: 'no_obligation', auto_create_signup_page: false)

      startup_monthly = Chargify::Product.create(name: 'Startup - Monthly', price_in_cents: 6900, 
        description: 'The startup plan billed per month', 
        product_family_id: old_product_family.id, interval_unit: 'month', interval: 1, initial_charge_in_cents: 0, trial_price_in_cents: 0, 
        trial_interval: 1, trial_interval_unit: 'month', taxable: true, 
        trial_type: 'no_obligation', auto_create_signup_page: false)

      entrepreneur_monthly = Chargify::Product.create(name: 'Entrepreneur - Monthly', price_in_cents: 9900, 
        description: 'The entrepreneur plan billed per month', 
        product_family_id: old_product_family.id, interval_unit: 'month', interval: 1, initial_charge_in_cents: 0, trial_price_in_cents: 0, 
        trial_interval: 1, trial_interval_unit: 'month', taxable: true, 
        trial_type: 'no_obligation', auto_create_signup_page: false)

      business_monthly = Chargify::Product.create(name: 'Business - Monthly', price_in_cents: 12900, 
        description: 'The business plan billed per month', 
        product_family_id: old_product_family.id, interval_unit: 'month', interval: 1, initial_charge_in_cents: 0, trial_price_in_cents: 0, 
        trial_interval: 1, trial_interval_unit: 'month', taxable: true, 
        trial_type: 'no_obligation', auto_create_signup_page: false)

      corporate_monthly = Chargify::Product.create(name: 'Corporate - Monthly', price_in_cents: 18900, 
        description: 'The corporate plan billed per month', 
        product_family_id: old_product_family.id, interval_unit: 'month', interval: 1, initial_charge_in_cents: 0, trial_price_in_cents: 0, 
        trial_interval: 1, trial_interval_unit: 'month', taxable: true, 
        trial_type: 'no_obligation', auto_create_signup_page: false)

      corporate_plus_monthly = Chargify::Product.create(name: 'Corporate Plus - Monthly', price_in_cents: 24900, 
        description: 'The corporate plus plan billed per month', 
        product_family_id: old_product_family.id, interval_unit: 'month', interval: 1, initial_charge_in_cents: 0, trial_price_in_cents: 0, 
        trial_interval: 1, trial_interval_unit: 'month', taxable: true, 
        trial_type: 'no_obligation', auto_create_signup_page: false)


      secret_starter_yearly = Chargify::Product.create(name: 'Secret Starter - Yearly', price_in_cents: 37820, 
        description: 'The secret starter plan billed per year', 
        product_family_id: old_product_family.id, interval_unit: 'month', interval: 12, initial_charge_in_cents: 0, trial_price_in_cents: 0, 
        trial_interval: 1, trial_interval_unit: 'month', taxable: true, 
        trial_type: 'no_obligation', auto_create_signup_page: false)

      startup_yearly = Chargify::Product.create(name: 'Startup - Yearly', price_in_cents: 74500, 
        description: 'The startup plan billed per year', 
        product_family_id: old_product_family.id, interval_unit: 'month', interval: 12, initial_charge_in_cents: 0, trial_price_in_cents: 0, 
        trial_interval: 1, trial_interval_unit: 'month', taxable: true, 
        trial_type: 'no_obligation', auto_create_signup_page: false)

      entrepreneur_yearly = Chargify::Product.create(name: 'Entrepreneur - Yearly', price_in_cents: 106900, 
        description: 'The entrepreneur plan billed per year', 
        product_family_id: old_product_family.id, interval_unit: 'month', interval: 12, initial_charge_in_cents: 0, trial_price_in_cents: 0, 
        trial_interval: 1, trial_interval_unit: 'month', taxable: true, 
        trial_type: 'no_obligation', auto_create_signup_page: false)

      business_yearly = Chargify::Product.create(name: 'Business - Yearly', price_in_cents: 139300, 
        description: 'The business plan billed per year', 
        product_family_id: old_product_family.id, interval_unit: 'month', interval: 12, initial_charge_in_cents: 0, trial_price_in_cents: 0, 
        trial_interval: 1, trial_interval_unit: 'month', taxable: true, 
        trial_type: 'no_obligation', auto_create_signup_page: false)

      corporate_yearly = Chargify::Product.create(name: 'Corporate - Yearly', price_in_cents: 204100, 
        description: 'The corporate plan billed per year', 
        product_family_id: old_product_family.id, interval_unit: 'month', interval: 12, initial_charge_in_cents: 0, trial_price_in_cents: 0, 
        trial_interval: 1, trial_interval_unit: 'month', taxable: true, 
        trial_type: 'no_obligation', auto_create_signup_page: false)

      corporate_plus_yearly = Chargify::Product.create(name: 'Corporate Plus - Yearly', price_in_cents: 268900, 
        description: 'The corporate plus plan billed per year', 
        product_family_id: old_product_family.id, interval_unit: 'month', interval: 12, initial_charge_in_cents: 0, trial_price_in_cents: 0, 
        trial_interval: 1, trial_interval_unit: 'month', taxable: true, 
        trial_type: 'no_obligation', auto_create_signup_page: false)
      # end of old pricing plans


      # the new pricing plan
      product_family = Chargify::ProductFamily.create(name: 'Public Pricing Plans', 
        description: 'These are the plans that any homewatch company can sign up for directly from the website')

      product = Chargify::Product.create(name: 'Qridit Base Plan', price_in_cents: 4000, 
        description: 'This is the base plan that includes the base fee and the free number (3) of QRIDs', 
        product_family_id: product_family.id, interval_unit: 'month', interval: 1, initial_charge_in_cents: 0, trial_price_in_cents: 0, 
        trial_interval: 1, trial_interval_unit: 'month', taxable: true, 
        trial_type: 'no_obligation', auto_create_signup_page: false)

      component = Chargify::ProductFamily::Component.create(name: 'QRIDs', description: 'The maximum number of QRIDs used in a monthly 
        billing period', unit_name: 'qrid', pricing_scheme: 'tiered', prices: [{ starting_quantity: 4, 
        ending_quantity: 50, unit_price: 2.50 }, { starting_quantity: 51, 
        ending_quantity: 250, unit_price: 1.99 }, { starting_quantity: 251, 
        ending_quantity: 350, unit_price: 1.75 }, { starting_quantity: 351, 
        ending_quantity: 9999, unit_price: 1.50 }], product_family_id: product_family.id, 
        kind: 'quantity_based_component', taxable: true)

      nhwa_coupon = Chargify::ProductFamily::Coupon.create(name: 'NHWA Discount Coupon', code: 'NHWA00110OFF', 
        description: 'This is the 10% of discount for National Homewatch Association Members', percentage: 10, 
        allow_negative_balance: false, recurring: true, product_family_id: product_family.id)
      # end of new pricing plans

    end

    task create_diane_plan: :environment do
      # Affiliate pricing plan
      product_family = Chargify::ProductFamily.create(name: 'Affiliate Pricing Plans', 
        description: 'These are the plans that affiliate based subscriptions are based on')

      product = Chargify::Product.create(name: 'Diane Affiliate Plan', price_in_cents: 0, 
        description: 'This is the the container subscription for Diane\'s affiliate system', 
        product_family_id: product_family.id, interval_unit: 'month', interval: 1, initial_charge_in_cents: 0, trial_price_in_cents: 0, 
        trial_interval: 1, trial_interval_unit: 'month', taxable: true, 
        trial_type: 'no_obligation', auto_create_signup_page: false)
    end

    task setup_diane_affiliates: :environment do

      product_family = Chargify::ProductFamily.find_by_handle('affiliate-pricing-plans')

      # find all the tenants that are affiliates
      Admin::Tenant.where("parent_id IS NOT NULL").where(affiliate_status: 'APPROVED').each do |tenant|
        if tenant.affiliate_chargify_resource.nil?
          chargify_resource = Admin::AffiliateChargifyResource.new
        else
          chargify_resource = tenant.affiliate_chargify_resource
        end

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

        # now save all the current allocations

        Apartment::Tenant.switch "tenant#{tenant.id}"

        subscription = Chargify::Subscription.find(tenant.affiliate_owner.billing_subscription_id)

        # if subscription.trial_ended_at <= Time.now
        #   # the honeymoon is over

          
        # end

        allocation = Chargify::Allocation.create(subscription_id: subscription.id, 
          component_id: tenant.affiliate_chargify_resource.base_component_id, 
          quantity: 1, memo: "Affiliate base fee applied", 
          proration_upgrade_scheme: 'full-price-delay-capture', proration_downgrade_scheme: 'no-prorate')

        allocation = Chargify::Allocation.create(subscription_id: subscription.id, 
          component_id: tenant.affiliate_chargify_resource.qrids_component_id, 
          quantity: Tenant::Qrid.where(status: 'Active').count, memo: "Affiliate bootstrapped with the allocated number of QRIDs on #{Time.now.strftime('%Y-%m-%d %H:%M:%S %z')}", 
          proration_upgrade_scheme: 'full-price-delay-capture', proration_downgrade_scheme: 'no-prorate')

      end
      
    end
  end


end
