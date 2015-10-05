class Tenant::SitesDatatable < Tenant::Datatable
  delegate :params, :sites_qrids, :tenant_site_url, :tenant_client_url, :tenant_zones_url, 
    :sites_buttons, :link_to, to: :@view

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Tenant::Site.count,
      iTotalDisplayRecords: sites.total_entries,
      aaData: data
    }
  end

private

  def data
    sites.map do |resource|
      qrids = {}
  
      resource.qrids.active.order(:name).each do |qrid|
        qrids[qrid.id] = qrid.name
      end

      #abort resource.inspect if qrids.size > 0

      [
        link_to(resource.name, tenant_site_url(id: resource)),
        link_to(resource.owner.name, tenant_client_url(id: resource.owner_id)),
        resource.owner.client_type,
        resource.address.try(:city),
        (resource.zone ? link_to(resource.zone.try(:name), tenant_zones_url) : ''),
        sites_qrids(qrids),
        sites_buttons(resource, nil)
      ]
    end
  end

  def sites
    @sites ||= fetch_sites
  end

  def fetch_sites
    sites = @resources


    case sort_column
    when 'site'
      sites = sites.order(name: sort_direction.to_sym)  
    when 'client'
      sites = sites.order("tenant_users.name #{sort_direction.upcase}")
    when 'client_type'
      sites = sites.order("tenant_sites.client_type #{sort_direction.upcase}")  
    when 'city'
      sites = sites.order("tenant_addresses.city #{sort_direction.upcase}")  
    when 'zone'
      sites = sites.order("tenant_zones.name #{sort_direction.upcase}")
    else
      sites = sites.order(:name)
    end

    sites = sites.page(page).per_page(per_page)
    if params[:sSearch].present?
      sites = sites.where("tenant_sites.name like :search", search: "%#{params[:sSearch]}%")
    end

    sites
  end

  
  def sort_column
    columns = %w[site client client_type city zone ]
    columns[params[:iSortCol_0].to_i]
  end
end