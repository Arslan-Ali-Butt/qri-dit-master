class Tenant::SearchController < ApplicationController
  def search
    @query = Riddle::Query.escape(params[:q])

    if current_user.role?(:admin) || current_user.role?(:manager)
      client_role = Tenant::Role.find_by!(name: 'Client')
      search_options = {
          tenant: Apartment::Tenant.current_tenant,
          page: 1,
          per_page: 5
      }
      @clients = Tenant::Client.search @query, search_options.merge(with: {role_ids: [client_role.id]})
      @users = Tenant::Staff.search @query, search_options.merge(without: {role_ids: [client_role.id]})
      @sites = Tenant::Site.search @query, search_options
      @qrids = Tenant::Qrid.search @query, search_options
    end
  end
end
