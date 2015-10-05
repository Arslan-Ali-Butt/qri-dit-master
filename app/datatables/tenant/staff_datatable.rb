class Tenant::StaffDatatable < Tenant::Datatable
  delegate :params, :staff_status, :staff_buttons , :link_to, :tenant_site_url, :tenant_client_url, :tenant_zones_url, 
    :tenant_work_types_url, :url_for, :controller_name, :time_from_sec, :staff_zones, 
    to: :@view

  def initialize(view, resources, worked_this_week, current_user)
    @view = view
    @resources = resources
    @worked_this_week = worked_this_week
    @current_user = current_user
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Tenant::Staff.count,
      iTotalDisplayRecords: staff.total_entries,
      aaData: data
    }
  end

private

  def data
    staff.map do |resource|

      #abort resource.inspect if qrids.size > 0

      [
        staff_status(resource),
        resource.id,
        link_to(resource.name, url_for(controller: controller_name, action: :show, id: resource)),
        resource.roles.first.name,
        staff_zones(resource),
        time_from_sec(@worked_this_week ? @worked_this_week[resource.id] : 0),
        staff_buttons(resource, @current_user)
      ]
    end
  end

  def staff
    @staff ||= fetch_staff
  end

  def fetch_staff
    staff = @resources#.order("#{sort_column} #{sort_direction}")


    case sort_column
    when 'status'
      staff = staff.order("tenant_users.status #{sort_direction.upcase}")  
    when 'id'
      staff = staff.order("tenant_users.id #{sort_direction.upcase}")
    when 'name'
      staff = staff.order("tenant_users.name #{sort_direction.upcase}")  
    when 'role'
      #staff = staff.order("tenant_roles.name #{sort_direction.upcase}")  
    when 'worked_this_week'
      staff = staff.order(time_this_week: sort_direction.to_sym)
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
    columns = %w[status id name role base_zone worked_this_week ]
    columns[params[:iSortCol_0].to_i]
  end
end