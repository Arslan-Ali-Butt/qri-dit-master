json.id resource.id
json.name resource.name

# put estimated duration into seconds
json.estimated_duration resource.estimated_duration.present? ? (resource.estimated_duration * 60 * 60).to_f : 0.0

json.instruction resource.instruction.present? ? resource.instruction : ''

json.key_box_code resource.key_box_code.present? ? resource.key_box_code : ""

if ENV['API_WEB_ENDPOINT']
  protocol = request.ssl? ? "https://" : "http://"

  json.qrid_url "#{protocol}#{@tenant.subdomain}.#{ENV['API_WEB_ENDPOINT']}#{start_tenant_my_qrid_path(resource)}"
else
  json.qrid_url start_tenant_my_qrid_url(resource)
end

if @features[:flat_task_list]
  json.tasks do
    tasks=resource.tasks.join_recursive { |query|
      query
          .start_with(parent_id: nil)
          .connect_by(id: :parent_id)
          .order_siblings(position: :asc)

    }
              .where(active: true)
              .where(checked: true)
    json.array! tasks do |task|
      json.id task.id
      json.parent_id task.parent_id.nil? ? 0 : task.parent_id
      json.lft task.position
      json.rgt 0
      json.depth task.depth
      json.name task.name
      json.task_type task.task_type
    end
  end
  json.permatasks do
    permaroots=resource.permatasks.order(position: :asc).uniq
    permatasks=[]
    permaroots.each do |root|
      permatasks<<root
      root.descendants.each do |task|
        permatasks<<task
      end
    end
    json.array! permatasks do |task|
      json.id task.id
      json.parent_id task.parent_id.nil? ? 0 : task.parent_id
      json.lft task.position
      json.rgt 0
      json.depth task.depth
      json.name task.name
      json.task_type task.task_type
    end
  end
else
  # build out all the various job types available for this QRID
  jobs = []
  jobs << { permatask_id: 0, name: "#{resource.name} - #{resource.work_type.name}" }
  resource.permatasks.where(parent_id: nil).each do |task|
    jobs << { permatask_id: task.id, name: task.name }
  end

  json.jobs jobs do |job|
    json.id "#{resource.id}_#{job[:permatask_id]}"
    json.permatask_id job[:permatask_id]
    json.name job[:name]

    if job[:permatask_id] == 0
      tasks = resource.tasks.where(active: true, checked: true).roots
    else
      tasks = Tenant::Permatask.where(id: job[:permatask_id])
    end

    json.tasks tasks do |task|

      json.partial! 'api/v0/tenant/qrids/task', task: task
    end
  end
end

json.site do
  if @features[:full_site]
    json.id resource.site.id
    json.address do
      json.number resource.site.address.house_number
      json.street resource.site.address.street_name
      json.line_2 resource.site.address.line_2
      json.city resource.site.address.city
      json.province resource.site.address.province
      json.postal_code resource.site.address.postal_code
      json.country resource.site.address.country
    end
    json.instruction resource.site.instruction.present? ? resource.site.instruction : ''
  else
    json.id resource.site.id
    json.name resource.site.name
    json.notes resource.site.notes.present? ? resource.site.notes : ''
    json.instruction resource.site.instruction.present? ? resource.site.instruction : ''
  end
  if resource.site.latitude.nil? or resource.site.longitude.nil?
    # Timbuktu's coordinates
    json.latitude 16.7758
    json.longitude 3.0094
  else
    json.latitude resource.site.latitude.to_f
    json.longitude resource.site.longitude.to_f
  end

  json.alarm_code resource.site.alarm_code.present? ? resource.site.alarm_code : (resource.alarm_code.present? ? resource.alarm_code : "")
  json.alarm_safeword resource.site.alarm_safeword.present? ? resource.site.alarm_safeword : (resource.alarm_safeword.present? ? resource.alarm_safeword : "")
  json.alarm_company resource.site.alarm_company.present? ? resource.site.alarm_company : (resource.alarm_company.present? ? resource.alarm_company : "")
end

json.client do
  json.id resource.site.owner.id
  json.name resource.site.owner.name
end

