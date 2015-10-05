class Tenant::ClientsDatatable < Tenant::Datatable
  delegate :params, :clients_status, :clients_sites, :clients_zones, :clients_cities, :clients_qrids, 
    :clients_work_types, :clients_buttons , :link_to, :tenant_site_url, :tenant_client_url, :tenant_zones_url, 
    :tenant_work_types_url, :url_for, :controller_name, 
    to: :@view

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Tenant::Client.count,
      iTotalDisplayRecords: clients.total_entries,
      aaData: data
    }
  end

private

  def data
    clients.map do |resource|
      sites = {}
      zones = {}
      cities = {}
      qrids = {}
      work_types = {}
      resource.sites.active.order(:name).each do |site|
        sites[site.id] = site.try(:name)
        zones[site.id] = site.zone.try(:name)
        cities[site.id]  = site.address.try(:city)
        site.qrids.active.order(:name).each do |qrid|
          qrids[qrid.id] = qrid.name
          work_types[qrid.id] = qrid.work_type.name
        end
      end

      #abort resource.inspect if qrids.size > 0

      [
        clients_status(resource),
        resource.id,
        link_to(resource.name, url_for(controller: controller_name, action: :show, id: resource)),
        resource.client_type,
        clients_sites(sites),
        clients_zones(zones),
        clients_cities(cities),
        clients_qrids(qrids),
        clients_work_types(work_types),
        clients_buttons(resource)
      ]
    end
  end

  def clients
    @clients ||= fetch_clients
  end

  def fetch_clients
    clients = @resources#.order("#{sort_column} #{sort_direction}")


    case sort_column
    when 'status'
      clients = clients.order(status: sort_direction.to_sym)  
    when 'id'
      clients = clients.order(id: sort_direction.to_sym)
    when 'client'
      clients = clients.order(name: sort_direction.to_sym)  
    when 'client_type'
      clients = clients.order(client_type: sort_direction.to_sym)  
    when 'site'
      clients = clients.order("tenant_sites.name #{sort_direction.upcase}")
    when 'zone'
      clients = clients.order("tenant_zones.name #{sort_direction.upcase}")
    when 'city'
      clients = clients.order("tenant_addresses.city #{sort_direction.upcase}")
    end

    clients = clients.page(page).per_page(per_page)
    if params[:sSearch].present?
      clients = clients.where("tenant_users.name like :search", search: "%#{params[:sSearch]}%")
    end

    clients
  end

  
  def sort_column
    columns = %w[status id client client_type site zone city ]
    columns[params[:iSortCol_0].to_i]
  end
end