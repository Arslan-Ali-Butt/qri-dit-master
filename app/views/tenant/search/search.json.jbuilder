if @clients
  json.clients do
    json.title 'Clients'
    json.list @clients do |resource|
      json.extract! resource, :id
      json.name resource.name
      json.url tenant_client_url(resource)
    end
  end
end

if @users
  json.users do
    json.title 'Staff'
    json.list @users do |resource|
      json.extract! resource, :id
      json.name resource.name
      json.url tenant_staff_url(resource)
    end
  end
end

if @sites
  json.sites do
    json.title 'Sites'
    json.list @sites do |resource|
      json.extract! resource, :id
      json.name resource.name
      json.subtitle resource.owner.name
      json.url tenant_site_url(resource)
    end
  end
end

if @qrids
  json.qrids do
    json.title 'QRIDs'
    json.list @qrids do |resource|
      json.extract! resource, :id
      json.name resource.name
      json.subtitle "#{resource.site.owner.name} - #{resource.site.name} - #{resource.work_type.name}"
      json.url tenant_qrid_url(resource)
    end
  end
end
