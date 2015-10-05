class TenantConstraint
  def self.matches?(request)
    if /\A\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\z/.match(request.host)
      false
    else
      Admin::Tenant.cached_find_by_host(request.host).present?
    end
  end
end
