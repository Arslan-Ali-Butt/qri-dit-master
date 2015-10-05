json.array!(@resources) do |resource|
  json.extract! resource, :id
  json.title "#{resource.assignee.name} - #{resource.qrid.site.name} - #{resource.qrid.site.address.try(:city)} - #{resource.qrid.name}"
  json.start resource.start_at
  json.end resource.end_at
  json.color event_color(resource)
  json.textColor event_text_color(resource)
  json.allDay false
  json.url url_for(controller: controller_name, action: :edit, id: resource)

  json.assignee_id resource.assignee_id
  json.qrid_id resource.qrid_id
  json.comment resource.comment
  json.assignee resource.assignee.name
  json.status resource.status
  json.site resource.qrid.site.name
  json.latitude resource.qrid.site.latitude
  json.longitude resource.qrid.site.longitude
  json.updated_at resource.updated_at
  json.start_at resource.start_at.strftime("%k:%M %z")
  json.work_type resource.qrid.work_type.name
  json.url_view url_for(controller: controller_name, action: :show, id: resource)
  json.recurrence  resource.recurrence
  json.qrid_name resource.qrid.name
  json.start_at_dt resource.start_at.strftime("%b %d %k:%M")
end
