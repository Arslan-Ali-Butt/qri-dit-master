module Tenant::TasksHelper
  def render_sortable_tree(tree, controller_name, nominating = false, qridless_editor = false, nodes_with_exclamations = [])
    renderer = Utils::SortableTreeRenderer.new(self, tree, controller_name, nominating, qridless_editor, nodes_with_exclamations)
    renderer.render
  end
end
