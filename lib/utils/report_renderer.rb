module Utils
  class ReportRenderer
    def initialize(helper, tree, checked)
      @helper = helper
      @tree = tree
      @children = []
      tree.each do |node|
        id = node.parent_id || 0
        @children[id].nil? ? (@children[id] = [node]) : @children[id] << node
      end
      @checked = checked
    end

    def render
      render_tree()
      # @children.inspect.to_s
    end

    private

    def render_tree(node = nil)
      result = ''

      if node
        if !node.respond_to?(:origin_id) || !@checked.nil? || node.origin_id.blank? || node.checked
          if @children[node.id]
            @children[node.id].each do |child|
              if @checked.nil?    # common tasks
                if !node.respond_to?(:origin_id) || node.checked || node.origin_id.nil? || node.origin_id.blank?              
                  result << render_tree(child)
                end
              else  # permatasks
                #unless node.task_type == 'Group' && !@checked.include?(node.id) && child.task_type == 'Question'
                  result << render_tree(child)
                #end
              end
            end
          end
          result = render_node(node, result)
        end

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
      case node.task_type
        when 'Group'
          "<fieldset>
          <legend>#{node.name}</legend>
          #{children}
          </fieldset>"
        when 'Question' 
          "<div class='question'>
            <label class='control-label'>#{node.name}</label>
            <div class='controls checklist-controls'>#{children}</div>
          </div>"
        when 'Answer'
          "<div class='answers checklist-answers'>
            <input class='qrid-radio' type='radio' name='tenant_report[questions][#{node.parent_id}]' id='tenant_report[questions][#{node.id}]' value='#{node.name}' required>
            <label for='tenant_report[questions][#{node.id}]' class='radio radio-#{node.name.camelize(:lower) == "n::A" ? "na" : node.name.camelize(:lower) }'>#{node.name}</label>
            #{"<div class='qrid-options' style='display:none'>#{children}</div>" if children.present?}
          </div>"
        when 'Comment'
          "<div class='action'><label class='control-label'>#{node.name}</label><br>
          <textarea name='tenant_report[comments][#{node.id}]' placeholder='Enter comment here' rows='5'></textarea></div>"
        when 'Photo'
          "<div class='action'><label class='control-label'>#{node.name}</label><div class='report-photo'><input type='file' name='tenant_report_photo[photo]' placeholder='#{node.name}'><input type='hidden' name='tenant_report_photo[task_id]' value='#{node.id}'></div><div class='reportphoto-collection' id='collection_#{node.id}'></div><div id='progress_#{node.id}' class='report_photo_progress'></div></div>"
        when 'Instructions'
          "<div class='action'><div class='report-instructions'>
           <label class='control-label'>#{node.name}</label>
           <input type='hidden' name='tenant_report[instructions][#{node.id}]' value='incomplete'><input type='checkbox' name='tenant_report[instructions][#{node.id}]' value='done'>
           #{"<div class='qrid-options'>#{children}</div>" if children.present?}
          </div></div>"
      end
    end
  end
end
