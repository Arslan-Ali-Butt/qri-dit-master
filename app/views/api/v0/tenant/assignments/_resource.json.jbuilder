json.id resource.id
json.title "#{resource.assignee.name} - #{resource.qrid.site.name} - #{resource.qrid.site.address.try(:city)} - #{resource.qrid.name}"
json.start resource.start_at.to_i
json.end resource.end_at.to_i
json.assignee_id resource.assignee_id
json.assignee resource.assignee.name
json.comment resource.comment.present? ? resource.comment : ''
json.status resource.status
  

json.site do
  if @features[:full_site]
    json.id resource.qrid.site.id
    json.address do
      json.number resource.qrid.site.address.house_number
      json.street resource.qrid.site.address.street_name
      json.line_2 resource.qrid.site.address.line_2
      json.city resource.qrid.site.address.city
      json.province resource.qrid.site.address.province
      json.postal_code resource.qrid.site.address.postal_code
      json.country resource.qrid.site.address.country
    end
    json.instruction resource.qrid.site.instruction.present? ? resource.qrid.site.instruction : ''
  else
    json.id resource.qrid.site.id
    json.name resource.qrid.site.name
    json.notes resource.qrid.site.notes.present? ? resource.qrid.site.notes : ''
  end
  if resource.qrid.site.latitude.nil? or resource.qrid.site.longitude.nil?
    # Timbuktu's coordinates
    json.latitude 16.7758
    json.longitude 3.0094
  else
    json.latitude resource.qrid.site.latitude.to_f
    json.longitude resource.qrid.site.longitude.to_f
  end
end

json.client do
  json.id resource.qrid.site.owner.id
  json.name resource.qrid.site.owner.name
end

json.qrid do
  json.id resource.qrid.id
  json.name resource.qrid.name
  json.estimated_duration (resource.qrid.estimated_duration * 60 * 60).to_f # put estimated duration into seconds

  json.client do
    json.id resource.qrid.site.owner.id
    json.name resource.qrid.site.owner.name
  end
end

json.updated_at resource.updated_at.to_i
json.work_type resource.qrid.work_type.name
json.recurrence  resource.recurrence.nil? ? "" : resource.recurrence

json.confirmed resource.confirmed ? true : false