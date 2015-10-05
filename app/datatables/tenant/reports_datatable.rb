class Tenant::ReportsDatatable < Tenant::Datatable
  delegate :params, :time_from_sec, :report_status, :report_flagged, :report_qrid_name, 
    :report_latest_unread_client_comment, :report_buttons, :link_to, :controller_name, 
    :tenant_staff_url, :tenant_client_url, :tenant_site_url, :tenant_work_types_url,
    to: :@view

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Tenant::Report.where.not(submitted_at: nil).count,
      iTotalDisplayRecords: reports.total_entries,
      aaData: data
    }
  end

private

  def data
    reports.map do |resource|
      #abort resource.inspect if resource.submitted_at.nil?
      [
        report_status(resource, controller_name),
        report_flagged(resource),
        resource.id,
        report_qrid_name(resource),
        link_to((resource.reporter.nil? ? 'Unknown' : resource.reporter.name), tenant_staff_url(id: resource.reporter_id)),
        link_to(resource.qrid.site.name, tenant_site_url(id: resource.qrid.site_id)),
        link_to(resource.qrid.site.owner.name, tenant_client_url(id: resource.qrid.site.owner_id)),
        link_to(resource.qrid.work_type.name, tenant_work_types_url),
        resource.submitted_at,
        time_from_sec((resource.qrid.estimated_duration || 0) * 3600),
        ((resource.submitted_at.present? and resource.started_at.present?) ? time_from_sec(resource.submitted_at - resource.started_at) : 'Unknown'),
        report_latest_unread_client_comment(resource),
        report_buttons(resource, controller_name)
      ]
    end
  end

  def reports
    @reports ||= fetch_reports
  end

  def fetch_reports
    reports = @resources#.order("#{sort_column} #{sort_direction}")
    case sort_column
    when 'status'
      if sort_direction == "asc"
        reports = reports.order(unread_by_manager: :asc, report_unread_notes_count: :asc, unread_by_client: :asc)
      else
        reports = reports.order(unread_by_manager: :desc, report_unread_notes_count: :desc, unread_by_client: :desc)
      end
    when 'flagged'
      reports = reports.order(flagged: sort_direction.to_sym)
    when 'id'
      reports = reports.order(id: sort_direction.to_sym)
    when 'qrid'
      reports = reports.order("tenant_qrids.name #{sort_direction.upcase}")
    when 'reporter'
      reports = reports.order("tenant_users.name #{sort_direction.upcase}")
    when 'site'
      reports = reports.order("tenant_sites.name #{sort_direction.upcase}")
    when 'client'
      reports = reports.order("tenant_users.name #{sort_direction.upcase}")
    when 'work_type'
      reports = reports.order("tenant_work_types.name #{sort_direction.upcase}")
    when 'submitted'
      reports = reports.order(submitted_at: sort_direction.to_sym)
    when 'est'
      reports = reports.order("tenant_qrids.estimated_duration #{sort_direction.upcase}")
    when 'logged'
      reports = reports.order(logged: sort_direction.to_sym)
    when 'latest_unread_client_comment'
      reports = reports.order(latest_unread_client_comment_timestamp: sort_direction.to_sym)
    else
      reports = reports.order(submitted_at: :desc)
    end

    reports = reports.page(page).per_page(per_page)
    if params[:sSearch].present?
      reports = reports.where("lower(tenant_qrids.name) like lower(:search) or lower(tenant_users.name) like lower(:search) or lower(tenant_sites.name) like lower(:search)", search: "%#{params[:sSearch]}%")
    end
    reports
  end

  
  def sort_column
    columns = %w[status flagged id qrid reporter site client work_type submitted est logged latest_unread_client_comment ]
    columns[params[:iSortCol_0].to_i]
  end
end