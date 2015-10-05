json.array!(@resources) do |resource|
  json.extract! resource, :id
  json.title "(#{time_from_sec(resource.submitted_at - resource.started_at)})"
  json.start resource.started_at
  json.end resource.started_at + 1.hour
  json.color event_color(resource.assignment)
  json.textColor event_text_color(resource.assignment)
  json.allDay false
  json.url url_for(controller: controller_name, action: :show, id: resource)
end
