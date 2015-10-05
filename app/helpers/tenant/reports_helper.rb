module Tenant::ReportsHelper
  def time_from_sec(t)
    secs = t.to_i
    Time.at(secs).utc.strftime('%Hh %Mm %Ss')
  rescue => ex
    '#ERROR#'
  end

  def report_status(resource, controller_name)

    if resource.unread_by_manager
      link_to url_for(controller: controller_name, action: :show, id: resource) do
        content_tag :i, { class: 'customicons message_new', rel: 'tooltip', title: 'Unopened Report' } do
          hidden_field_tag 'status_sort_priority', 0
        end
      end
          
    elsif resource.client_notes.where(unread_by_manager: true).count > 0
      link_to url_for(controller: controller_name, action: :show, id: resource, anchor: "comment-#{resource.client_notes.where(unread_by_manager: true).last.id}") do
        content_tag :i, { class: 'customicons message_new', rel: 'tooltip', title: 'Unread message from client' } do
          hidden_field_tag 'status_sort_priority', 1        
        end
      end

    elsif resource.unread_by_client == true
      link_to url_for(controller: controller_name, action: :show, id: resource) do
        content_tag :i, { class: 'customicons message_sent', rel: 'tooltip', title: 'Sent report' } do
          hidden_field_tag 'status_sort_priority', 3
        end
      end
    else
      link_to url_for(controller: controller_name, action: :show, id: resource) do
        content_tag :i, { class: 'customicons message_full', rel: 'tooltip', title: 'Opened report' } do
          hidden_field_tag 'status_sort_priority', 2
        end
      end
    end
  end

  def report_flagged(resource)
    if resource.flagged
      content_tag :i, { class: 'customicons flag' } do
        hidden_field_tag 'flagged_sort_priority', 0
      end 
    else
      hidden_field_tag 'flagged_sort_priority', 1
    end
  end

  def report_qrid_name(resource)
    qrid_name = resource.qrid.name
    if resource.is_permatask_report
      qrid_name = "#{qrid_name} (Permatask)"
    end

    link_to qrid_name, trial_tenant_qrid_url(id: resource.qrid_id)
  end

  def report_latest_unread_client_comment(resource)
    if !resource.client_notes.where(unread_by_manager: true).empty?
      content_tag(:span, resource.client_notes.where(unread_by_manager: true).last.note) + 
      content_tag(:span, hidden_field_tag('comment_sort_priority', resource.client_notes.where(unread_by_manager: true).last.created_at.to_i))
    else
      hidden_field_tag 'comment_sort_priority', 0
    end
  end

  def report_buttons(resource, controller_name)
    tenant_button(:show, url_for(controller: controller_name, action: :show, id: resource), {rel:"tooltip",title:"View report"} ) + 
    tenant_button(:photo, tenant_report_photos_url(report_id: resource.id),{rel:"tooltip",title:"View photos attached to this report"} )
  end

end
