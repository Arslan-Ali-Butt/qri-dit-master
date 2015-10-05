module Tenant::QridsHelper
  def render_static_tree(tree, checked)
    if tree.empty?
      raw "<li><p class='form-control-static'>There are no checklists yet.</p></li>"
    else
      renderer = Utils::StaticTreeRenderer.new(self, tree, checked)
      renderer.render
    end
  end

  def render_report(tree, checked = nil)
    renderer = Utils::ReportRenderer.new(self, tree, checked)
    renderer.render
  end

  def qrids_repeat(assignment)
    # options = {qrid_id: resource.id, status: ['Open', 'In Progress']}
    # assignment = Tenant::Assignment.list(Time.now, Time.now + 30.day, options).first

    unless assignment.nil?

      data = { id: assignment.id }
      unless assignment.recurrence.nil?
        data[:instance_start] = assignment.start_at.to_time.strftime('%FT%T%:z ')
        data[:instance_end] = assignment.end_at.to_time.strftime('%FT%T%:z ')
        data[:qrid_id] = assignment.qrid.id
        data[:comment] = assignment.comment
      end
    end

    assignment_recurrence(assignment)
  end

  def qrids_next_assigned(assignment)
    if assignment
      data = { id: assignment.id }

      link_to assignment.start_at, edit_tenant_assignment_url(data), remote: true
    end
  end

  def qrids_overdue(options)
    assignments = Tenant::Assignment.list(Time.now - 30.day, Time.now, options)

    content_tag(:ul) do
      assignments.reject {|row| row.qrid.nil? }.map do |assignment|
        
        data = { id: assignment.id }
        data[:instance_start] = assignment.start_at.to_time.strftime('%FT%T%:z ')
        data[:instance_end] = assignment.end_at.to_time.strftime('%FT%T%:z ')
        data[:qrid_id] = assignment.qrid.id
        data[:comment] = assignment.comment
        concat(content_tag(:li, link_to(assignment.start_at, edit_tenant_assignment_url(data), remote: true)))
      end
    end
  end

  def qrids_buttons(resource, return_path)
    tenant_button(:show, trial_tenant_qrid_url(id: resource.id, return_path: (defined?(return_path) ? return_path : '')),{rel: "tooltip",title:"View QRID"}) + 
    tenant_button(:edit, edit_tenant_qrid_url(id: resource.id, return_path: (defined?(return_path) ? return_path : '')),{rel: "tooltip",title:"Edit QRID"}) + 
    tenant_button(:assign, tenant_qrid_url(id: resource.id, return_path: (defined?(return_path) ? return_path : '')),{rel: "tooltip",title:"Create Assignment"}) + 
    tenant_button(:qrcode, qrcard_tenant_qrid_url(id: resource.id, return_path: (defined?(return_path) ? return_path : '')), {remote: true,rel: "tooltip",title:"Print QRID Card"}) + 
    tenant_button(:photo, tenant_qrid_photos_url(qrid_id: resource.id, return_path: (defined?(return_path) ? return_path : '')),{rel:"tooltip",title:"Manage Photos"}) +    
    tenant_button(:delete, delete_tenant_qrid_url(id: resource.id, return_path: (defined?(return_path) ? return_path : '')), {remote: true,rel: "tooltip",title:"Trash"})
  end
end
