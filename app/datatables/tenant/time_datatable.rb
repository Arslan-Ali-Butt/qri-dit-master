class Tenant::TimeDatatable < Tenant::Datatable
  delegate :params, :time_base_zone, :time_last_report, :time_this_week, :time_this_month, :time_buttons, 
  :tenant_time_url, :link_to, :tenant_site_url, :tenant_client_url, :tenant_zones_url, 
  to: :@view

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Tenant::Staff.by_role(['Admin', 'Manager', 'Reporter']).active.count,
      iTotalDisplayRecords: staff.total_entries,
      aaData: data
    }
  end

private

  def data
    staff.map do |resource|
      [
        link_to(resource.name, tenant_time_url(id: resource.id)),
        time_base_zone(resource),
        time_last_report(resource).to_s,
        time_this_week(resource),
        time_this_month(resource),
        time_buttons(resource)
      ]
    end
  end

  def staff
    @staff ||= fetch_staff
  end

  def fetch_staff
    staff = @resources#.order("#{sort_column} #{sort_direction}")


    case sort_column
    when 'reporter_name'
      staff = staff.order("tenant_users.name #{sort_direction.upcase}")
    when 'last_report_at'
      staff = staff.order(last_report_at: sort_direction.to_sym)
    when 'time_this_week'
      staff = staff.order(time_this_week: sort_direction.to_sym)
    when 'time_this_month'
      #raise sort_direction
      staff = staff.order(time_this_month: sort_direction.to_sym)
    else
      staff = staff.order("tenant_users.name #{sort_direction.upcase}")
    end

    
    staff = staff.page(page).per_page(per_page)
    if params[:sSearch].present?
      staff = staff.where("tenant_users.name like :search", search: "%#{params[:sSearch]}%")
    end

    staff
  end

  
  def sort_column
    columns = %w[reporter_name base_zone last_report_at time_this_week time_this_month ]
    columns[params[:iSortCol_0].to_i]
  end
end