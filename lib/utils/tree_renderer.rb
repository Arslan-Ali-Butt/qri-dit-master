module Utils
  class TreeRenderer
    def initialize(helper, tree, controller_name = nil, nominating = false, qridless_editor = false, nodes_with_exclamations = [])
      @helper = helper
      @tree = tree
      @children = []
      tree.each do |node|
        id = node.parent_id || 0
        @children[id].nil? ? (@children[id] = [node]) : @children[id] << node
      end
      @controller_name = controller_name
      @nominating = nominating
      @qridless_editor = qridless_editor
      @nodes_with_exclamations = nodes_with_exclamations
    end

    def render
      render_tree()
    end

    private

    def render_tree(node = nil)
      result = ''

      if node
        if @children[node.id]
          @children[node.id].each do |child|
            result << render_tree(child)
          end
        end
        result = render_node(node, result)
      else
        roots = @children[0]
        # define roots, if it's need
        if roots.nil? && !@tree.empty?
          min_parent_id = @tree.map(&:parent_id).compact.min
          roots = @tree.select{ |n| n.parent_id == min_parent_id }          
        end

        if roots
          roots.each do |root|
            result << render_tree(root)
          end
        end
      end

      @helper.raw result
    end

    def render_node(node, children = nil)
      "<li class='data-resource-id='#{node.id}'>
        <div>
          #{node.name}
        </div>
        #{"<ol'>#{children}</ol>" if children.present?}
      </li>"
    end
  end
end