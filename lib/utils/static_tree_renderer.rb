module Utils
  class StaticTreeRenderer < TreeRenderer
    def initialize(helper, tree, checked)
      super(helper, tree)
      @checked = checked
    end

    private

    def render_node(node, children = nil)
      "<li class='dd-item dd3-item col-lg-12' data-resource-id='#{node.id}'>
        <label class='dd-checkbox col-lg-1'><input name='tenant_qrid[permatask_ids][]' type='checkbox' value='#{node.id}'#{@checked.include?(node.id) ? ' checked' : ''}></label>
        <div class='dd3-content col-lg-11 tree-item-#{node.task_type.downcase}'>
          #{node.name}
        </div>
        #{"<ol class='dd-list'>#{children}</ol>" if children.present?}
      </li>"
    end
  end
end
