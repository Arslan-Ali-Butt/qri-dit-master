require 'apartment/elevators/subdomain'

module Apartment
  module Elevators
    #   Provides a rack based tenant switching solution based on subdomains
    #   Assumes that tenant name should match subdomain
    #
    class QuickReportSystems < Generic
      
      def parse_tenant_name(request)
        #abort request.env['HTTP_HOST'].split('.').first.inspect
        if /\A\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\z/.match(request.host)
          nil
        elsif request.env['HTTP_HOST'].split('.').first == 'api'
          tenant = Admin::Tenant.cached_find_by_host(request.env['HTTP_X_COMPANY_DOMAIN'])
          tenant ? "tenant#{tenant.id}" : nil
        else
          tenant = Admin::Tenant.cached_find_by_host(request.env['HTTP_HOST'])
          tenant ? "tenant#{tenant.id}" : nil
        end
      end
    end
  end
end