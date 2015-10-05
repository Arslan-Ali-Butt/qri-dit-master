class Tenant::QridsDatatable < Tenant::Datatable
  delegate :params, :qrids_repeat, :qrids_next_assigned, :qrids_overdue, :qrids_buttons, 
  :trial_tenant_qrid_url, :link_to, :tenant_site_url, :tenant_client_url, :tenant_zones_url, 
  :tenant_work_types_url, 
  to: :@view

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Tenant::Qrid.count,
      iTotalDisplayRecords: qrids.total_entries,
      aaData: data
    }
  end

private

  def data
    qrids.map do |resource|
      options = {qrid_id: resource.id, status: ['Open', 'In Progress']}
      assignment = resource.next_assignment

      [
        link_to(resource.name, trial_tenant_qrid_url(id: resource.id, return_path: (defined?(return_path) ? return_path : ''))),
        link_to(resource.site.name, tenant_site_url(id: resource.site_id)),
        link_to(resource.site.owner.try(:name), tenant_client_url(id: resource.site.owner_id)),
        resource.site.owner.client_type,
        resource.site.address.try(:city),
        (resource.site.zone ? link_to(resource.site.zone.try(:name), tenant_zones_url) : ''),
        link_to(resource.work_type.name, tenant_work_types_url),
        qrids_repeat(assignment),
        qrids_next_assigned(assignment),
        #assignment ? assignment.start_at.to_i : 10000000000,
        qrids_overdue(options),
        qrids_buttons(resource, '')
      ]
    end
  end

  def qrids
    @qrids ||= fetch_qrids
  end

  def fetch_qrids
    qrids = @resources#.order("#{sort_column} #{sort_direction}")


    case sort_column
    when 'qrid'
      qrids = qrids.order(name: sort_direction.to_sym)
    when 'site'
      qrids = qrids.order("tenant_sites.name #{sort_direction.upcase}")
    when 'client'
      qrids = qrids.order("tenant_users.name #{sort_direction.upcase}")
    when 'client_type'
      qrids = qrids.order("tenant_users.client_type #{sort_direction.upcase}")
    when 'city'
      qrids = qrids.order("tenant_addresses.city #{sort_direction.upcase}")
    when 'zone'
      qrids = qrids.order("tenant_sites.name #{sort_direction.upcase}")
    when 'work_type'
      qrids = qrids.order("tenant_work_types.name #{sort_direction.upcase}")
    when 'next_assigned'
      Tenant::Qrid.generate_next_assignment_timestamps

      qrids = qrids.order(next_assignment_timestamp: sort_direction.to_sym)
    end

    qrids = qrids.page(page).per_page(per_page)
    if params[:sSearch].present?
      qrids = qrids.where("tenant_qrids.name like :search", search: "%#{params[:sSearch]}%")
    end

    qrids.each do |qrid|
      options = {qrid_id: qrid.id, status: ['Open', 'In Progress']}
      assignment = Tenant::Assignment.list(Time.now, Time.now + 30.day, options).first

      #abort qrid.inspect if assignment.present?
      qrid.next_assignment = assignment
    end

    qrids
  end

  
  def sort_column
    columns = %w[qrid site client client_type city zone work_type repeat next_assigned ]
    columns[params[:iSortCol_0].to_i]
  end
end