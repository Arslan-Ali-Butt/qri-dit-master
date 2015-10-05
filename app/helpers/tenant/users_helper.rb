module Tenant::UsersHelper
  def role_switcher_class(role)
    case role
      when 'Admin'
        'switch switch-important'
      when 'Manager'
        'switch switch-warning'
      when 'Reporter'
        'switch switch-info'
      when 'Client'
        'switch switch-success'
      else
        'switch'
    end
  end

  def clients_status(resource)
    if (resource.invitation_sent_at.blank? and resource.invitation_accepted_at.blank?)
      content_tag :span, { class: "label", style:"background:#767fd7" } do
        "#{resource.status}(UNINVITED)"
      end  
    elsif (resource.invitation_sent_at.present? and resource.invitation_accepted_at.blank?)
      content_tag :span, { class: "label",style:"background:#767fd7" } do
        "#{resource.status}(INVITED)"
      end  
    else
      content_tag :span, { class: resource_status_class(resource.status) } do
        resource.status
      end
    end
  end

  alias_method :staff_status, :clients_status

  def clients_sites(sites)
    content_tag(:ul) do
      sites.map do |id, name|
        concat(content_tag(:li, link_to(name, tenant_site_url(id: id))))
      end
    end
  end

  def clients_zones(zones)
    content_tag(:ul) do
      zones.map do |id, name|
        concat(content_tag(:li, (name ? link_to(name, tenant_zones_url) : '')))
      end
    end
  end

  def clients_cities(cities)
    content_tag(:ul) do
      cities.map do |id, name|
        concat(content_tag(:li, name))
      end
    end
  end

  def clients_qrids(qrids)
    content_tag(:ul) do
      qrids.map do |id, name|
        concat(content_tag(:li, link_to(name, tenant_qrid_url(id: id))))
      end
    end
  end

  def clients_work_types(work_types)
    content_tag(:ul) do
      work_types.map do |id, name|
        concat(content_tag(:li, link_to(name, tenant_work_types_url)))
      end
    end
  end

  def clients_buttons(resource)
    tenant_button(:show, tenant_client_url(id: resource), {rel:"tooltip",title:"View client details"}) + 
    tenant_button(:edit, edit_tenant_client_url(id: resource), {rel:"tooltip",title:"Edit client"}) + 
    if resource.status != 'Deleted'
      tenant_button(:delete, delete_tenant_client_url(id: resource), {remote: true,rel:"tooltip",title:"Delete client"}) 
    else
      tenant_button(:delete, delete_tenant_client_url(id: resource), {remote: true,rel:"tooltip",title:"Permanently delete client"}) + 
      tenant_button(:undo_delete, restore_tenant_client_url(id: resource),{rel:"tooltip",title:"Restore client"})
    end
  end

  def staff_zones(resource)
    content_tag(:ul) do
      resource.staff_zones.order(:name).map do |zone|
        concat(content_tag(:li, link_to(zone.name, tenant_zones_url)))
      end
    end
  end

  def staff_buttons(resource, current_user)
    buttons = tenant_button(:show, url_for(controller: controller_name, action: :show, id: resource),{rel:"tooltip",title:"View team member details"}) + 
    tenant_button(:edit, url_for(controller: controller_name, action: :edit, id: resource),{rel:"tooltip",title:"Edit team member"})
    unless current_user.id == resource.id
      buttons += tenant_button(:delete, url_for(controller: controller_name, action: :delete, id: resource),{remote: true,rel:"tooltip",title:"Delete team member"})
    end

    buttons
  end
end
