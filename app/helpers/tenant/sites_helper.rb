module Tenant::SitesHelper
  def sites_qrids(qrids)
    content_tag(:ul) do
      qrids.map do |id, name|
        concat(content_tag(:li, link_to(name, tenant_qrid_url(id: id))))
      end
    end
  end

  

  def sites_buttons(resource, return_path)
    tenant_button(:show, tenant_site_url(id: resource, return_path: return_path), { rel: "tooltip", title: "View site details" }) + 
    tenant_button(:edit, edit_tenant_site_url(id: resource, return_path: return_path), { rel:"tooltip",title:"Edit site" }) + 
    tenant_button(:delete, delete_tenant_site_url(id: resource, return_path: return_path), { remote: true, rel: "tooltip", title: "Delete site"})
  end

end
