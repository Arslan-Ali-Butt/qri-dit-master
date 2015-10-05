module Utils
  class SortableTreeRenderer < TreeRenderer
    include Rails.application.routes.url_helpers

    private
    def render_node(node, children = nil)
      @node_type = node.task_type.downcase
      "#{
      if(@controller_name=='tasks'||@controller_name=='permatasks')
        if (Admin::Tenant.find(Apartment::Database.current_tenant.match(/\d+/).to_s.to_i).allow_affiliate_requests&&node.depth==0) then
          "<input #{(node.for_affiliates) ? "checked='checked'" : ""} onchange=\"for_affiliates('#{(@controller_name=='tasks')?tenant_task_path(node):tenant_permatask_path(node)}',this,'#{(@controller_name=='tasks')?'tenant_task':'tenant_permatask'}')\" type='checkbox'>"
        else
          ''
        end
      end
      }
      #{(node.respond_to?(:checked) && node.checked) || @nominating || @augmenting || @qridless_editor ? "<li class='dd-item dd3-item' data-resource-id='#{node.id}'>
        #{node.respond_to?(:origin_id) && node.origin_id ? "#{!@nodes_with_exclamations.nil? && @nodes_with_exclamations.include?(node.origin_id) ? (node.checked ? '<i class=\'fa fa-pencil modified-version-exists\' rel=\'tooltip\' title=\'This is a modified instance of the original template task.\'></i>' : '<i class=\'fa fa-star modified-version-exists\' rel=\'tooltip\' title=\'This is the original template task.\'></i>') : ''}
        <label #{@nominating ? "" : "style='display:none;'"} class='dd-checkbox' data-origin-id=#{node.origin_id}><input name='tenant_qrid[default_task_ids][]' type='checkbox' value='#{node.id}' #{node.respond_to?(:checked) && node.checked ? ' checked disabled' : ''}></label>" : ""}
        <div class='dd3-content #{@node_type}'>
          <span data-task-type='#{node.task_type}' class='#{node.active ? 'active' : 'blocked'} #{@node_type == 'answer' || @nominating ?  '' : 'editable'}'>#{node.name} #{@node_type == 'photo' ? "<i class='fa fa-camera' rel='tooltip' title='Conditional photo request'></i>" : @node_type == 'comment' ? "<i class='fa fa-comment' rel='tooltip' title='Conditional comment request'></i>" : @node_type == 'question' ? "<i class='glyphicon icon-q' rel='tooltip' title='Ask a question'></i>" : ''}</span>
          <div class='controls'>
            #{@node_type == 'question' ? @helper.link_to("Yes".html_safe, "#", remote: false, class: 'btn btn-default toggle', rel: 'tooltip', title: '"Yes" Condition', data:{'toggle-condition' => 'Yes'}) : ''}
            #{@node_type == 'question' ? @helper.link_to("No".html_safe, "#", remote: false, class: 'btn btn-default toggle', rel: 'tooltip', title: '"No" Condition', data:{'toggle-condition' => 'No'}) : ''}
            #{@node_type == 'question' ? @helper.link_to("N/A".html_safe, "#", remote: false, class: 'btn btn-default toggle', rel: 'tooltip', title: '"N/A" Condition', data:{'toggle-condition' => 'N/A'}) : ''}
            #{(@node_type == 'question' || @node_type == 'instructions') && !@nominating ? "<span class='btn btn-default add-node' data-resource-id='#{node.id}' data-resource-type='Photo'><i class='fa fa-camera' rel='tooltip' title='Conditional photo request'></i></span>" : ''}
            #{(@node_type == 'question' || @node_type == 'instructions') && !@nominating  ? "<span class='btn btn-default add-node' data-resource-id='#{node.id}' data-resource-type='Comment'><i class='fa fa-comment' rel='tooltip' title='Conditional comment request'></i></span>" : ''}
            #{(@node_type == 'group') && !@nominating && node.parent.nil? ? "<a href='#{ node.class.to_s == "Tenant::Task" ? trial_tenant_task_path(node, :format => :js) : trial_tenant_permatask_path(node, :format => :js)}' class='btn btn-default preview' data-resource-id='#{node.id}' data-remote='true' role='button' rel='tooltip' title='Preview'><i class='fa fa-eye'></i></a>" : ''}
            #{(@node_type == 'group') && !@nominating ? "<span class='btn btn-default expand-group' data-resource-id='#{node.id}'><i class='glyphicon glyphicon-chevron-down' rel='tooltip' title='Expand this entire group'></i></span>" : ''}
            #{@node_type == 'question' || @node_type == 'answer' || @node_type == 'instructions' ? '' : Sortable::NESTING_RULES[node.task_type].empty? ? '' : !@nominating ? "<span class='btn btn-default add-node' data-resource-id='#{node.id}' data-resource-type='Group'><i class='fa fa-th-large' rel='tooltip' title='Create sub group'></i></span>" : ''}
            #{(@node_type == 'group' || @node_type == 'question') && !@nominating ? "<span class='btn btn-default add-instructions' data-resource-id='#{node.id}' data-resource-type='Instructions'><i class='glyphicon glyphicon-info-sign' rel='tooltip' title='Provide an instruction'></i></span>" : ''}
            #{(@node_type == 'group' || @node_type == 'question') && !@nominating ? "<span class='btn btn-default add-node' data-resource-id='#{node.id}' data-resource-type='Question'><i class='glyphicon icon-q' rel='tooltip' title='Ask a question'></i></span>" : ''}
            #{(@node_type == 'answer') || @nominating  ? '' : @helper.link_to("<i class='fa fa-trash-o' rel='tooltip' title='Trash'></i>".html_safe, @helper.url_for(controller: @controller_name, action: :destroy, id: node), method: :delete, data: { confirm: 'Are you sure?' }, remote: true, class: 'btn btn-danger')}
          </div>
        </div>
        <ol class='dd-list'>
          #{children}
        </ol>
      </li>" : ""}"
    end
  end
end