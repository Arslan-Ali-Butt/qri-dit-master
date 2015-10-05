module Tenant::TimeHelper
  def time_base_zone(resource)
    content_tag(:ul) do
      resource.staff_zones.order(:name).map do |zone|
        concat(content_tag(:li, link_to(zone.name, tenant_zones_url)))
      end
    end
  end

  def time_last_report(resource)
    last_report = Tenant::Report.where(reporter_id: resource.id).where.not(submitted_at: nil).order(submitted_at: :desc).first
    last_report ? last_report.submitted_at : ''
  end

  def time_this_week(resource)

    reports_this_week = Tenant::Report.where(reporter_id: resource.id).where(submitted_at: Time.now.all_week)
    time_this_week = 0
    reports_this_week.each do |rep|
      time_this_week += rep.submitted_at - rep.started_at
    end


    time_from_sec(time_this_week)
  end

  def time_this_month(resource)
    reports_this_month = Tenant::Report.where(reporter_id: resource.id).where(submitted_at: Time.now.all_month)
    time_this_month = 0
    reports_this_month.each do |rep|
      time_this_month += rep.submitted_at - rep.started_at
    end

    time_from_sec(time_this_month)
  end

  def time_buttons(resource)
    tenant_button :time, tenant_time_url(id: resource.id),{rel:"tooltip",title:"View reporter's work history"}
  end

end
