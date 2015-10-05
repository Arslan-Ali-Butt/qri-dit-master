class CouponValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.present?
      begin
        record.errors[attribute] << (options[:message] || 'is not an active coupon code.') if !CouponValidator::active?(value)
      rescue => ex
        record.errors[attribute] << (options[:message] || 'is not a valid coupon code.')
      end
    end
  end

  def self.active?(coupon_code, admin_email)
    product_family = Chargify::ProductFamily.find_by_handle('public-pricing-plans')

    coupon = Chargify::Coupon.find_by_product_family_id_and_code(product_family.id, coupon_code)

    if coupon.archived_at.nil?
      active = true
    else
      active = false
    end

    redeemable = true   # TODO, figure out how to calculate max redemptions, doesn't seem to work at the moment

    redeemable && active

  rescue => ex
    false
  end

  def self.description(coupon_code, admin_email)
    if coupon_code
      if CouponValidator::active?(coupon_code, admin_email)
        product_family = Chargify::ProductFamily.find_by_handle('public-pricing-plans')

        coupon = Chargify::Coupon.find_by_product_family_id_and_code(product_family.id, coupon_code)

        coupon.description
      else
        "<span style='color:#df4843'><span style='text-decoration:underline'>#{coupon_code}</span> is not an active coupon code.</span>".html_safe
      end
    else
      "No coupon code was given."   
    end
  end
end